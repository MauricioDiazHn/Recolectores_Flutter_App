import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recolectores_app_flutter/models/rive_asset.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/src/recolectas/api_constants.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'package:flutter/services.dart';
import 'package:recolectores_app_flutter/src/recolectas/recolectas_view.dart';

class RecolectasDetallesView extends StatefulWidget {
  final List<RecolectaItem> items;

  const RecolectasDetallesView({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<RecolectasDetallesView> createState() =>
      _RecolectasDetallesViewState();
}

class _RecolectasDetallesViewState extends State<RecolectasDetallesView> {
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
            // Usar cantIngresada si existe, si no, usar la cantidad original
            int cantidadInicial;
            if (producto['cantIngresada'] != null) {
              cantidadInicial = producto['cantIngresada'];
            } else {
              cantidadInicial = producto['cantidad'];
            }
            
            _cantidadesRecogidas[orden]![nombreProducto] = cantidadInicial;
            
            String controllerKey = '${orden}_$nombreProducto';
            _controllers[controllerKey] = TextEditingController(text: cantidadInicial.toString());
          }
          
          // Verificar el estado inicial del switch basado en las cantidades
          _verificarCantidadesCompletas(orden, ordenData['productos']);
        }
      });
    } catch (e) {
      showError('Error al inicializar los datos: $e');
    }
  }

  void _initializeSwitchStates(List<Map<String, dynamic>> ordenes) {
    for (var ordenData in ordenes) {
      // El switch se basa en el estado de la orden
      _isApprovedMap[ordenData['orden']] = 
          ordenData['estado']?.toLowerCase() == 'recolectada';
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
    bool allDisabled = _allOrdersDisabled();

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
              onPressed: () {
                if (allDisabled) {
                  // Si todas las órdenes están deshabilitadas, solo navegar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RecolectasView()),
                  );
                  return;
                }
                
                // Si no están todas deshabilitadas, ejecutar la lógica de guardado
                _showConfirmationDialog();
              },
              child: const Text('Guardar'),
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

  List<Widget> _buildProductDetailsWithInputs(List<dynamic> productos, int orden) {
    // Obtener el estado de la orden actual
    var ordenActual = _orderData.firstWhere((o) => o['orden'] == orden);
    bool canEdit = _canEditOrder(ordenActual['estado'] ?? '');

    return productos.map<Widget>((producto) {
      String productName = producto['nombre'];
      int cantidadMaxima = producto['cantidad'];
      int cantidad = _cantidadesRecogidas[orden]?[productName] ?? 0;
      
      String controllerKey = '${orden}_$productName';
      _controllers[controllerKey] ??= TextEditingController(text: cantidad.toString());
      
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          highlightColor: Colors.green.withOpacity(0.2),
          splashColor: Colors.green.withOpacity(0.3),
          onTap: canEdit ? () {
            setState(() {
              if (_cantidadesRecogidas[orden]?[productName] == null || 
                  _cantidadesRecogidas[orden]?[productName] == 0) {
                _cantidadesRecogidas[orden]![productName] = cantidadMaxima;
                _controllers[controllerKey]?.text = cantidadMaxima.toString();
              } else {
                _cantidadesRecogidas[orden]![productName] = 0;
                _controllers[controllerKey]?.text = "0";
              }
              _verificarCantidadesCompletas(orden, productos);
            });
          } : null,
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
                    enabled: canEdit,
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

  void _verificarCantidadesCompletas(int orden, List<dynamic> productos) {
    bool todasCantidadesCompletas = productos.every((producto) {
      String nombreProducto = producto['nombre'];
      int cantidadOriginal = producto['cantidad'];
      int cantidadIngresada = _cantidadesRecogidas[orden]?[nombreProducto] ?? 0;
      return cantidadIngresada == cantidadOriginal;
    });

    setState(() {
      _isApprovedMap[orden] = todasCantidadesCompletas;
    });
  }

  bool _canEditOrder(String estado) {
    estado = estado.toLowerCase();
    return estado == 'pendiente' || estado == 'en ruta';
  }

  bool _allOrdersDisabled() {
    return _orderData.every((orden) {
      String estado = (orden['estado'] ?? '').toLowerCase();
      return estado == 'recolectada' || estado == 'incompleta'|| estado == 'fallida';
    });
  }

  Widget _buildSwitchField(int orden) {
    var ordenData = _orderData.firstWhere((o) => o['orden'] == orden);
    bool canEdit = _canEditOrder(ordenData['estado'] ?? '');
    bool isCompleted = ordenData['estado']?.toLowerCase() == 'recolectada';
    bool isFailed = ordenData['estado']?.toLowerCase() == 'fallida';

    // Definir colores
    final completedColor = Colors.green.withOpacity(0.8); // Verde intenso
    final partialColor = Colors.yellow.withOpacity(0.8); // Amarillo
    final failedColor = const Color.fromARGB(255, 255, 82, 82); // Rojo intenso

    return Row(
      children: [
        Switch(
          value: isCompleted,
          onChanged: canEdit ? (value) {
            setState(() {
              _isApprovedMap[orden] = value;
            });
          } : null,
          activeColor: completedColor,
          inactiveThumbColor: isCompleted ? completedColor : (isFailed ? failedColor : partialColor),
          inactiveTrackColor: isCompleted ? completedColor.withOpacity(0.1) : (isFailed ? failedColor.withOpacity(0.5) : partialColor.withOpacity(0.1)),
        ),
        const SizedBox(width: 10),
        Text(
          isCompleted ? 'Completo' : (isFailed ? 'Fallido' : 'Parcial'),
          style: TextStyle(
            color: isCompleted ? completedColor : (isFailed ? failedColor : partialColor),
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

  // Mover la lógica de guardado a un método separado
  Future<void> _guardarCambios() async {
    try {
      for (var item in widget.items) {
        final url = Uri.parse('$baseUrl/recolectaenc/${item.idRecolecta}');
        final token = UserSession.token;
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

        _orderData.forEach((ordenData) {
          int ordenCompraId = ordenData['orden'];
          ordenData['productos'].forEach((producto) {
            String nombreProducto = producto['nombre'];
            int cantidadRecogida = _cantidadesRecogidas[ordenCompraId]?[nombreProducto] ?? 
                                 producto['cantidad'];
            
            detalles.add({
              'ordenCompraId': ordenCompraId,
              'nombre': nombreProducto,
              'cantidad': cantidadRecogida,
              'estado': (producto['cantidad'] == cantidadRecogida) ? 'Recolectado' : 'Incompleta'
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
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados exitosamente para todos los registros.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecolectasView()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de que desea guardar los cambios?, Esta opcion no tiene reversion!!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _guardarCambios();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}


