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
  final List<RecolectaItem> items;

  const SampleItemDetailsView({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<SampleItemDetailsView> createState() =>
      _RecolectaItemDetailsViewState();
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
  List<Map<String, dynamic>> _orderData = [];

  // Agregar un mapa para los controladores
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    comentarioController = TextEditingController();
    _initializeData();
    _initializeState();
  }

  void _initializeData() {
    for (var item in widget.items) {
      _showDetailsMap[item.ordenCompraId] = false;
      _isApprovedMap[item.ordenCompraId] = false;
      _cantidadesRecogidas[item.ordenCompraId] = {};
    }
  }

  Future<void> _initializeState() async {
    try {

    List<Map<String, dynamic>> allOrdenes = [];

    for (var item in widget.items) {
      final ordenes = await _fetchOrderData(item.idRecolecta);
      allOrdenes.addAll(ordenes);
    }
    
      setState(() {
      _orderData = allOrdenes;
      _initializeSwitchStates(allOrdenes);
      _initializeDetailsVisibility(allOrdenes);

      for (var ordenData in allOrdenes) {
        final int orden = ordenData['orden'];
        _cantidadRecogidaMap[orden] = 0;
        
        // Inicializar el mapa para esta orden
        _cantidadesRecogidas[orden] = {};
        
        // Iterar sobre los productos y establecer las cantidades ingresadas
        for (var producto in ordenData['productos']) {
          String nombreProducto = producto['nombre'];
          int cantidadInicial = producto['cantIngresada'] ?? producto['cantidad'];
          _cantidadesRecogidas[orden]![nombreProducto] = cantidadInicial;
          
          String controllerKey = '${orden}_$nombreProducto';
          _controllers[controllerKey] = TextEditingController(text: cantidadInicial.toString());
        }
      }
    });
    } catch (e) {
      showError('Error al inicializar los datos: $e');
    }
  }

  void _initializeSwitchStates(List<Map<String, dynamic>> ordenes) {
    for (var ordenData in ordenes) {
      _isApprovedMap[ordenData['orden']] =
          widget.items.first.estado.toLowerCase() == 'parcial';
    }
  }

  void _initializeDetailsVisibility(List<Map<String, dynamic>> ordenes) {
    for (var ordenData in ordenes) {
      _showDetailsMap[ordenData['orden']] = false; // Inicialmente ocultos
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrderData(int encabezadoId) async {
    final String token = UserSession.token!;
    final String url = '$baseUrl/recolectaenc/recolectadet/$encabezadoId';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

      try {
        final response = await http.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) {
            final productos = (item['productos'] as List<dynamic>);
            int cantidadTotal = 0;
            for (var producto in productos) { // Itera sobre la lista de productos
              cantidadTotal += producto['cantidad'] as int;
            }

            return {
              'orden': item['ordenCompraId'],
              'cantidad': cantidadTotal,
              'nombreProyecto': item['nombreProyecto'],
              'comprador': item['comprador'],
              'productos': productos.map((producto) {
                return {
                  'nombre': producto['nombre'],
                  'cantidad': producto['cantidad'],
                  'cantIngresada': producto['cantIngresada'],
                };
              }).toList(),
            };
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
    // Limpiar los controladores
    for (var controller in _controllers.values) {
      controller.dispose();
    }
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
            _buildNonEditableField(
                label: 'Proveedor', value: widget.items.first.proveedor),
            _buildNonEditableField(
                label: 'Dirección', value: widget.items.first.direccion),
            _buildEditableField(
              label: 'Comentario',
              controller: comentarioController,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alinea a la izquierda
                children: _buildOrderDetails(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  for (var item in widget.items) {
                  final url = Uri.parse('$baseUrl/recolectaenc/${item.idRecolecta}');
                  final token = UserSession.token; // Recuperar el token
                  final headers = {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  };

                  final body = jsonEncode({
                    'Estado': _isApproved ? 'Aprobado' : 'Pendiente',
                    'Comentario': comentarioController.text,
                    'FechaAceptacion': DateTime.now().toIso8601String()
                  });

                  final response = await http.put(
                    url,
                    headers: headers,
                    body: body,
                  );

                  List<Map<String, dynamic>> detalles = [];

                  // Iterar sobre los datos recogidos para preparar el JSON
                  _orderData.forEach((ordenData) {
                    int ordenCompraId = ordenData['orden'];
                    ordenData['productos'].forEach((producto) {
                      String nombreProducto = producto['nombre'];
                      // Si no hay un valor ingresado, usar la cantidad original del producto
                      int cantidadRecogida = _cantidadesRecogidas[ordenCompraId]?[nombreProducto] ?? 
                                           producto['cantidad'];
                      
                      detalles.add({
                        'ordenCompraId': ordenCompraId,
                        'nombre': nombreProducto,
                        'cantidad': cantidadRecogida,
                        'estado': (_isApprovedMap[ordenCompraId] ?? false) ? 'Recolectado' : 'Pendiente'
                      });
                    });
                  });

                  final url2 = Uri.parse('$baseUrl/recolectaenc/detalles/update');

                  final body2 = jsonEncode(detalles);

                  final response2 = await http.put(
                    url2,
                    headers: headers,
                    body: body2,
                  );

                    if (response.statusCode != 200 && response2.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar cambios para idRecolecta: ${item.idRecolecta} - ${response.body}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // Salir si hay un error
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cambios guardados exitosamente para todos los registros.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SampleItemListView()), // Aquí ajusta el widget de inicio
                  );

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
    if (_orderData.isEmpty) {
    return [Text('No hay datos disponibles.')];
  }

  List<Widget> widgets = [];

  // Agrupar productos por orden de compra
  Map<int, List<dynamic>> ordersMap = {};
  for (var item in _orderData) {
    if (!ordersMap.containsKey(item['orden'])) {
      ordersMap[item['orden']] = [];
    }
    ordersMap[item['orden']]!.addAll(item['productos']);
  }
  

  // Crear widgets basados en los grupos de órdenes de compra
  ordersMap.forEach((orden, productos) {
    String? nombreProyecto = _orderData.firstWhere((data) => data['orden'] == orden)['nombreProyecto'];
    widgets.add(
        Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Orden: #$orden\nCant: ${productos.fold<int>(0, (int sum, item) => sum + (item['cantidad'] as int))}'),
                      Text(
                        'Proyecto: ${nombreProyecto ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'Comprador: ${_orderData.firstWhere((data) => data['orden'] == orden)['comprador'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildSwitchField(orden),
                ),
              ],
            ),
            subtitle: _showDetailsMap[orden] ?? false
                ? Column(
                    children: _buildProductDetailsWithInputs(productos, orden),
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
    });

    return widgets;
  }
  
List<Widget> _buildOrderDetailsWithInputs(List<RecolectaItem> items, int orden) {
    return items.map<Widget>((item) {
    int cantidad = _cantidadesRecogidas[orden]!['cantidad'] ?? item.cantidad;
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proveedor: ${item.proveedor}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Cantidad: ${item.cantidad}',
                  style: const TextStyle(fontSize: 12),
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
              controller: TextEditingController(
                text: cantidad.toString(),
              ),
              onChanged: (value) {
                setState(() {
                  _cantidadesRecogidas[orden]!['cantidad'] =
                      int.tryParse(value) ?? 0;
                });
              },
              decoration: const InputDecoration(
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

  void _verificarCantidadesCompletas(int orden, List<dynamic> productos) {
    bool todasCantidadesMaximas = true;
    
    for (var producto in productos) {
      String productName = producto['nombre'];
      int cantidadMaxima = producto['cantidad'];
      int cantidadActual = _cantidadesRecogidas[orden]?[productName] ?? 0;
      
      if (cantidadActual != cantidadMaxima) {
        todasCantidadesMaximas = false;
        break;
      }
    }

    setState(() {
      _isApprovedMap[orden] = todasCantidadesMaximas;
    });
  }

  List<Widget> _buildProductDetailsWithInputs(
      List<dynamic> productos, int orden) {
    return productos.map<Widget>((producto) {
      String productName = producto['nombre'];
      int cantidadMaxima = producto['cantidad'];
      int cantidad = _cantidadesRecogidas[orden]?[productName] ?? 0;
      
      // Crear una clave única para cada controlador
      String controllerKey = '${orden}_$productName';
      
      // Obtener o crear el controlador
      _controllers[controllerKey] ??= TextEditingController(text: cantidad.toString());
      
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          highlightColor: Colors.green.withOpacity(0.2),
          splashColor: Colors.green.withOpacity(0.3),
          onTap: () {
            setState(() {
              if (_cantidadesRecogidas[orden]?[productName] == null || 
                  _cantidadesRecogidas[orden]?[productName] == 0) {
                _cantidadesRecogidas[orden]![productName] = cantidadMaxima;
              } else {
                _cantidadesRecogidas[orden]![productName] = 0;
              }
              _verificarCantidadesCompletas(orden, productos);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Cantidad: $cantidadMaxima',
                        style: const TextStyle(fontSize: 12),
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
                    controller: _controllers[controllerKey],
                    onChanged: (value) {
                      int? inputValue = int.tryParse(value);
                      if (inputValue != null) {
                        if (inputValue > cantidadMaxima) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La cantidad no puede ser mayor a la cantidad original'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            _cantidadesRecogidas[orden]![productName] = cantidadMaxima;
                            _controllers[controllerKey]?.text = cantidadMaxima.toString();
                          });
                        } else if (inputValue < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La cantidad no puede ser menor a 0'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            _cantidadesRecogidas[orden]![productName] = 0;
                            _controllers[controllerKey]?.text = "0";
                          });
                        } else {
                          setState(() {
                            _cantidadesRecogidas[orden]![productName] = inputValue;
                            _controllers[controllerKey]?.text = inputValue.toString();
                          });
                        }
                        _verificarCantidadesCompletas(orden, productos);
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cant. Rec.',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        if (!(_isApprovedMap[orden] ??
            false)) // Mostrar solo si no está "Ready"
          SizedBox(
            width: 80, // Ajusta el ancho según tus necesidades
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ], // Solo números
              initialValue: _cantidadRecogidaMap[orden].toString(),
              onChanged: (value) {
                setState(() {
                  _cantidadRecogidaMap[orden] = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cant. Rec.',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8), // Ajusta el padding
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildProductDetails(List<dynamic> productos) {
    return productos
        .map((producto) => ListTile(
              title: Text(producto['nombre']),
              trailing: Text('Cantidad: ${producto['cantidad']}'),
            ))
        .toList();
  }

  Widget _buildSwitchField(int orden) {
    return Row(
      children: [
        Switch(
          value: _isApprovedMap[orden] ??
              false, //  Ajusta la lógica para el estado del switch
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
            color:
                (_isApprovedMap[orden] ?? false) ? Colors.green : Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fade(duration: 300.ms).scale(delay: 100.ms),
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
        style: TextStyle(
            fontSize: 18), // Aumenta el tamaño del texto dentro del campo
      ),
    );
  }
}
