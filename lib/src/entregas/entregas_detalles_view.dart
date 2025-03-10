import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/src/entregas/api_constants.dart';
import 'package:recolectores_app_flutter/src/services/UserSession.dart';
import 'package:flutter/services.dart';
import 'package:recolectores_app_flutter/src/entregas/entregas_view.dart';

class EntregasDetallesView extends StatefulWidget {
  final List<EntregaItem> items;

  const EntregasDetallesView({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<EntregasDetallesView> createState() => _EntregasDetallesViewState();
}

class _EntregasDetallesViewState extends State<EntregasDetallesView> {
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TextEditingController comentarioController;

  Map<int, bool> _showDetailsMap = {};

  Map<int, int> _cantidadEntregadaMap = {};
  Map<int, Map<String, int>> _cantidadesEntregadas = {};
  List<Map<String, dynamic>> _orderData = [];

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
    }
  }

  Future<void> _initializeState() async {
    try {
      List<Map<String, dynamic>> allOrdenes = [];

      for (var item in widget.items) {
        final ordenes = await _fetchOrderData(item.idEntrega);
        allOrdenes.addAll(ordenes);
      }
      
      setState(() {
        _orderData = allOrdenes;
        _initializeDetailsVisibility(allOrdenes);

        for (var ordenData in allOrdenes) {
          final int orden = ordenData['orden'];
          _cantidadEntregadaMap[orden] = 0;
          
          _cantidadesEntregadas[orden] = {};
          
          for (var producto in ordenData['productos']) {
            String nombreProducto = producto['nombre'];
            int cantidadInicial;
            if (producto['cantIngresada'] != null) {
              cantidadInicial = producto['cantIngresada'];
            } else {
              cantidadInicial = producto['cantidad'];
            }
            
            _cantidadesEntregadas[orden]![nombreProducto] = cantidadInicial;
            
            String controllerKey = '${orden}_$nombreProducto';
            _controllers[controllerKey] = TextEditingController(text: cantidadInicial.toString());
          }
          
          _verificarCantidadesCompletas(orden, ordenData['productos']);
        }
      });
    } catch (e) {
      showError('Error al inicializar los datos: $e');
    }
  }

  void _initializeDetailsVisibility(List<Map<String, dynamic>> ordenes) {
    for (var ordenData in ordenes) {
      _showDetailsMap[ordenData['orden']] = false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrderData(int encabezadoId) async {
    final String token = UserSession.token!;
    final String url = '$baseUrl/entregaenc/entregadet/$encabezadoId';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        return [{
          'orden': int.parse(data['ordenCompraId']),
          'estado': data['estado'],
          'nombreProyecto': data['nombreProyecto'],
          'comprador': data['comprador'],
          'productos': data['productos'].map((producto) {
            return {
              'nombre': producto['nombre'],
              'cantidad': producto['cantidad'],
              'cantIngresada': producto['cantIngresada'],
            };
          }).toList(),
        }];
      } else {
        throw Exception('Error al obtener los detalles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  void _verificarCantidadesCompletas(int orden, List<dynamic> productos) {
    for (var producto in productos) {
      String nombreProducto = producto['nombre'];
      int cantidadRequerida = producto['cantidad'];
      int cantidadIngresada = _cantidadesEntregadas[orden]?[nombreProducto] ?? 0;
      
      if (cantidadIngresada != cantidadRequerida) {
        return;
      }
    }
  }

  Future<void> _actualizarCantidades(int orden) async {
    String? token = UserSession.token;
    final url = Uri.parse('$baseUrl/entregaenc/actualizar/$orden');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    List<Map<String, dynamic>> productos = [];
    
    for (var producto in _orderData.firstWhere((o) => o['orden'] == orden)['productos']) {
      productos.add({
        'nombre': producto['nombre'],
        'cantIngresada': _cantidadesEntregadas[orden]![producto['nombre']]
      });
    }

    final body = jsonEncode({
      'productos': productos,
      'comentario': comentarioController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cantidades actualizadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        showError('Error al actualizar cantidades: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Widget _buildNonEditableField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Detalles de la Entrega'),
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
                label: 'Cliente', value: widget.items.first.proveedor),
            _buildNonEditableField(
                label: 'Dirección', value: widget.items.first.direccion),
            _buildEditableField(
              label: 'Comentario',
              controller: comentarioController,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: _orderData.map((ordenData) {
                  final int orden = ordenData['orden'];
                  final bool showDetails = _showDetailsMap[orden] ?? false;

                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Orden de Compra: $orden'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Proyecto: ${ordenData['nombreProyecto']}'),
                              Text('Comprador: ${ordenData['comprador']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  showDetails
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showDetailsMap[orden] = !showDetails;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (showDetails)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ...ordenData['productos'].map<Widget>((producto) {
                                  String nombreProducto = producto['nombre'];
                                  String controllerKey =
                                      '${orden}_$nombreProducto';
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(nombreProducto),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                _controllers[controllerKey],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Cantidad (${producto['cantidad']})',
                                              border: const OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              int cantidad =
                                                  int.tryParse(value) ?? 0;
                                              setState(() {
                                                _cantidadesEntregadas[orden]![
                                                    nombreProducto] = cantidad;
                                              });
                                              _verificarCantidadesCompletas(
                                                  orden,
                                                  ordenData['productos']);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () => _actualizarCantidades(orden),
                                  child: const Text('Guardar Cantidades'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    comentarioController.dispose();
    super.dispose();
  }
}
