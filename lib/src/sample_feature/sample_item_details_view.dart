// import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
// class SampleItemDetailsView extends StatelessWidget {
//   const SampleItemDetailsView({super.key});

//   static const routeName = '/sample_item';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Item Details'),
//       ),
//       body: const Center(
//         child: Text('More Information Here'),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recolectores_app_flutter/models/rive_asset.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/src/sample_feature/api_constants.dart';
import 'package:recolectores_app_flutter/src/sample_feature/sample_item_list_view.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'package:flutter/services.dart';

class SampleItemDetailsView extends StatefulWidget {
  final RecolectaItem item;

  const SampleItemDetailsView({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<SampleItemDetailsView> createState() => _RecolectaItemDetailsViewState();
}

class _RecolectaItemDetailsViewState extends State<SampleItemDetailsView> {

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isApproved = false; // Inicializamos _isApproved
  late TextEditingController comentarioController;

  Map<int, bool> _isApprovedMap = {};
  Map<int, bool> _showDetailsMap = {};

  Map<int, int> _cantidadRecogidaMap = {};
  Map<int, Map<String, int>> _cantidadesRecogidas = {};

  @override
  void initState() {
    super.initState();
    _isApproved = widget.item.estado.toLowerCase() == 'aprobado';
    comentarioController = TextEditingController(text: widget.item.comentario);


    _initializeState();
  }
Future<void> _initializeState() async {
  try {
    final ordenes = await _fetchOrderData(widget.item.idRecolecta); // API call
    setState(() {
      _initializeSwitchStates(ordenes);
      _initializeDetailsVisibility(ordenes);

      for (var ordenData in ordenes) {
        _cantidadRecogidaMap[ordenData['orden']] = 0;
      }

      for (var ordenData in ordenes) {
        _cantidadesRecogidas[ordenData['orden']] = {};
        for (var producto in ordenData['productos']) {
          _cantidadesRecogidas[ordenData['orden']]![producto['nombre']] = 0;
        }
      }
    });
  } catch (e) {
    showError('Error al inicializar los datos: $e');
  }
}

  void _initializeSwitchStates(List<Map<String, dynamic>> ordenes) {
  for (var ordenData in ordenes) {
    _isApprovedMap[ordenData['orden']] = widget.item.estado.toLowerCase() == 'parcial';
  }
}

  void _initializeDetailsVisibility(List<Map<String, dynamic>> ordenes) {
    for (var ordenData in ordenes) {
      _showDetailsMap[ordenData['orden']] = false; // Inicialmente ocultos
    }
  }

  List<Map<String, dynamic>> _getOrderData() {
      return [
      {'orden': widget.item.ordenCompraId, 'cantidad': 50, 'productos': [
        {'nombre': 'Producto A', 'cantidad': 20},
        {'nombre': 'Producto B', 'cantidad': 30},
      ]},
      {'orden': 12346, 'cantidad': 25, 'productos': [
        {'nombre': 'Producto C', 'cantidad': 25},
      ]},
      {'orden': 12347, 'cantidad': 100, 'productos': [
        {'nombre': 'Producto D', 'cantidad': 50},
        {'nombre': 'Producto E', 'cantidad': 30},
        {'nombre': 'Producto F', 'cantidad': 20},
      ]},
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchOrderData(int encabezadoId) async {
  final String token = UserSession.token!;
  final String url = '$baseUrl/recolectadet/$encabezadoId';

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
            'orden': item['OrdenCompraId'],
            'cantidad': item['Cantidad'],
            'productos': (item['Productos'] as List<dynamic>).map((producto) {
              return {
                'nombre': producto['Nombre'],
                'cantidad': producto['Cantidad'],
              };
            }).toList(),
          }).toList();
    } else {
      throw Exception('Error al obtener los detalles: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Detalles del Pedido'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNonEditableField(label: 'Proveedor', value: widget.item.proveedor),
            _buildNonEditableField(label: 'Dirección', value: widget.item.direccion),
            _buildEditableField(
              label: 'Comentario',
              controller: comentarioController,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
                children: _buildOrderDetails(),
              ),
            ),


            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final url = Uri.parse(
                      '$baseUrl/recolectaenc/${widget.item.idRecolecta}');
                  final token = UserSession.token; // Recuperar el token
                  final headers = {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  };

                  final body = jsonEncode(
                    {
                      'Estado': _isApproved ? 'Aprobado' : 'Pendiente',
                      'Comentario': comentarioController.text,
                      'FechaAceptacion': DateTime.now().toIso8601String()
                    }
                  );

                  final response = await http.put(
                    url,
                    headers: headers,
                    body: body,
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cambios guardados exitosamente.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SampleItemListView()), // Aquí ajusta el widget de inicio
                    );

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar cambios: ${response.body}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrderDetails() {
    //  Simulación de datos (reemplaza con tus datos reales)
    List<Map<String, dynamic>> ordenes = _getOrderData();
    List<Widget> widgets = [];
        
    for (var ordenData in ordenes) {
      int orden = ordenData['orden'];

      widgets.add(
        Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Orden: #$orden\nCant: ${ordenData['cantidad']}'),
                _buildSwitchField(orden), // Switch en el título
              ],
            ),
            subtitle: _showDetailsMap[orden] ?? false
                ? Column(
                    children: _buildProductDetailsWithInputs(ordenData['productos'], orden),
                  )
                : null,
            onTap: () {
              setState(() {
                _showDetailsMap[orden] = !(_showDetailsMap[orden] ?? false);
              });
            },
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildProductDetailsWithInputs(List<dynamic> productos, int orden) {
    return productos.map<Widget>((producto) {
      String productName = producto['nombre'];
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
              children: [
                Text(
                  productName,
                  style: TextStyle(fontWeight: FontWeight.bold), // Negrita para el nombre del producto (opcional)
                ),
                Text(
                  'Cantidad: ${producto['cantidad']}',
                  style: TextStyle(fontSize: 12), // Tamaño de letra más pequeño para la cantidad
                ),
              ],
            ),
          ),
           SizedBox(
            width: 80,
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              initialValue: _cantidadesRecogidas[orden]![productName].toString(),
               onChanged: (value) {
                setState(() {
                  _cantidadesRecogidas[orden]![productName] = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cant. Rec.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSwitchAndQuantity(int orden, int cantidadTotal) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSwitchField(orden),
        SizedBox(width: 8),
        // Campo de texto para la cantidad recogida
        if (!(_isApprovedMap[orden] ?? false)) // Mostrar solo si no está "Ready"
          SizedBox(
            width: 80,  // Ajusta el ancho según tus necesidades
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Solo números
              initialValue: _cantidadRecogidaMap[orden].toString(),
              onChanged: (value) {
                setState(() {
                  _cantidadRecogidaMap[orden] = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cant. Rec.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8), // Ajusta el padding
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildProductDetails(List<dynamic> productos) {

    return productos.map((producto) =>
        ListTile(
          title: Text(producto['nombre']),
          trailing: Text('Cantidad: ${producto['cantidad']}'),
        )
    ).toList();

  }

   Widget _buildSwitchField(int orden) {
    return Row(
      children: [
        Switch(
          value: _isApprovedMap[orden] ?? false, //  Ajusta la lógica para el estado del switch
          onChanged: (value) {
            setState(() {
              _isApprovedMap[orden] = value;
            });
          },
          activeColor: Colors.green.withOpacity(0.8),
          inactiveThumbColor: Colors.yellow.withOpacity(0.8),
          inactiveTrackColor: Colors.yellow.shade200,
        ),
        const SizedBox(width: 10),
        Text(
          (_isApprovedMap[orden] ?? false) ? 'Completo' : 'Parcial',
          style: TextStyle(
            color: (_isApprovedMap[orden] ?? false) ? Colors.green : Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fade(duration: 300.ms)
            .scale(delay: 100.ms),
      ],
    );
  }



  Widget _buildNonEditableField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: 3, // Tamaño más grande para el campo de texto
        style: TextStyle(fontSize: 18), // Aumenta el tamaño del texto dentro del campo
      ),
    );
  }
}
