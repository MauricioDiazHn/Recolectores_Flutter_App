import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/components/no_connection_view.dart';
import 'package:recolectores_app_flutter/models/rive_asset.dart';
import 'package:recolectores_app_flutter/src/services/UserSession.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import '../settings/settings_view.dart';
import 'entregas_detalles_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'api_constants.dart';

class EntregasView extends StatefulWidget {
  const EntregasView({
    super.key,
  });

  static const routeName = '/entregas';

  @override
  State<EntregasView> createState() => _EntregasViewState();
}

class EntregaItem {
  final int idEntrega;
  final int ordenCompraId;
  final String proveedor;
  final String direccion;
  final DateTime fechaEntrega;
  final String horaEntrega;
  final DateTime? fechaAsignacion;
  final DateTime? fechaAceptacion;
  final int motoristaId;
  final int idVehiculo;
  final int kmInicial;
  final int kmFinal;
  final int? tiempoEnSitio;
  final int? evaluacionCliente;
  final String comentario;
  final int cantidad;
  final String estado;
  final DateTime fechaRegistro;
  final String tc;
  final String tituloTC;

  EntregaItem({
    required this.idEntrega,
    required this.ordenCompraId,
    required this.proveedor,
    required this.direccion,
    required this.fechaEntrega,
    required this.horaEntrega,
    this.fechaAsignacion,
    this.fechaAceptacion,
    required this.motoristaId,
    required this.idVehiculo,
    required this.kmInicial,
    required this.kmFinal,
    this.tiempoEnSitio,
    this.evaluacionCliente,
    required this.comentario,
    required this.cantidad,
    required this.estado,
    required this.fechaRegistro,
    required this.tc,
    required this.tituloTC,
  });

  factory EntregaItem.fromJson(Map<String, dynamic> json) {
    return EntregaItem(
      idEntrega: json['idlinea'] ?? 0,
      ordenCompraId: json['ordenCompraId'] ?? 0,
      proveedor: json['proveedor'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : DateTime.now(),
      horaEntrega: json['horaEntrega'] ?? '',
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : null,
      fechaAceptacion: json['fechaAceptacion'] != null
          ? DateTime.parse(json['fechaAceptacion'])
          : null,
      motoristaId: json['motoristaId'] ?? 0,
      idVehiculo: json['idVehiculo'] ?? 0,
      kmInicial: json['kmInicial'] ?? 0,
      kmFinal: json['kmFinal'] ?? 0,
      tiempoEnSitio: json['tiempoEnSitio'] ?? 0,
      evaluacionCliente: json['evaluacionCliente'] ?? 0,
      comentario: json['comentario'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      estado: json['estado'] ?? '',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
      tc: json['tc'] ?? '',
      tituloTC: json['tituloTC'] ?? '',
    );
  }
}

class _EntregasViewState extends State<EntregasView> {
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  bool _showMileageDialog = !UserSession.hasShownMileageDialog;
  TextEditingController _mileageController = TextEditingController();
  bool _isButtonExpanded = false;
  bool _showFinalizeButton = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _kmInicial;

  List<EntregaItem> items = [];

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAndShowMileageDialog();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      _showMileageDialog = false;
      _showFinalizeButton = false;
    });
    
    await fetchItems();
    
    if (!hasError && !isLoading) {
      await checkMileageStatus();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchItems();
    await checkMileageStatus();
  }

  Future<void> fetchItems() async {
    try {
      final url = Uri.parse('$baseUrl/entregaenc/GetByMotoristaId/${UserSession.motoristaId}');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          items = data.map((item) => EntregaItem.fromJson(item)).toList();
          isLoading = false;
          hasError = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Error al cargar las entregas. Por favor, intente de nuevo.';
          _showMileageDialog = false;
          _showFinalizeButton = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado. Por favor, intente de nuevo.';
        }
        _showMileageDialog = false;
        _showFinalizeButton = false;
      });
    }
  }

  Future<void> checkMileageStatus() async {
    if (hasError) {
      setState(() {
        _showMileageDialog = false;
        _showFinalizeButton = false;
      });
      return;
    }

    try {
      final hasEntered = await hasEnteredCurrentMileage(UserSession.motoristaId ?? 0);
      final hasFinalized = await hasFinalizedRecolecta(UserSession.motoristaId ?? 0);
      
      if (!hasError) {
        setState(() {
          _showMileageDialog = !hasEntered;
          _showFinalizeButton = !hasFinalized;
        });
        
        if (!hasEntered) {
          _showMilleageDialog();
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error al verificar el kilometraje. Por favor, intente de nuevo.';
        _showMileageDialog = false;
        _showFinalizeButton = false;
      });
    }
  }

  Future<bool> hasEnteredCurrentMileage(int motoristaId) async {
    try {
      final url = Uri.parse('$baseUrl/entregaenc/$motoristaId/currentMileage?checkFinalMileage=false');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return response.body == 'true';
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al verificar el kilometraje. Por favor, intente de nuevo.';
          _showMileageDialog = false;
          _showFinalizeButton = false;
        });
        return true; // Retornamos true para evitar mostrar el diálogo
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Error al verificar el kilometraje. Por favor, intente de nuevo.';
        }
        _showMileageDialog = false;
        _showFinalizeButton = false;
      });
      return true; // Retornamos true para evitar mostrar el diálogo
    }
  }

  Future<bool> hasFinalizedRecolecta(int motoristaId) async {
    try {
      final url = Uri.parse('$baseUrl/entregaenc/$motoristaId/currentMileage?checkFinalMileage=true');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return response.body == 'true';
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al verificar el estado de la entrega. Por favor, intente de nuevo.';
          _showMileageDialog = false;
          _showFinalizeButton = false;
        });
        return true; // Retornamos true para evitar mostrar el botón
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Error al verificar el estado de la entrega. Por favor, intente de nuevo.';
        }
        _showMileageDialog = false;
        _showFinalizeButton = false;
      });
      return true; // Retornamos true para evitar mostrar el botón
    }
  }

  void _showMilleageDialog() {
    if (hasError) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 66, 68),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingrese el kilometraje actual',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))
              ),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  hintText: 'Kilometraje',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_mileageController.text.isNotEmpty) {
                    setState(() {
                      final kmInicial = int.tryParse(_mileageController.text) ?? 0;
                      _submitKmInicial(UserSession.motoristaId ?? 0, kmInicial, 'En Ruta');
                      _showMileageDialog = false;
                      UserSession.hasShownMileageDialog = true;
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitKmInicial(int motoristaId, int kmInicial, String estado) async {
    final url = Uri.parse('$baseUrl/entregaenc/updateKmInicialAndStatus');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };
    final body = json.encode({
      'MotoristaId': motoristaId,
      'KmInicial': kmInicial,
      'Estado': estado,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Actualización exitosa: ${response.body}");
      } else {
        showError('Error al actualizar: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void _showFinalMileageDialog() {
    if (hasError) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 0, 66, 68),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ingrese el kilometraje final',
                        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_kmInicial != null)
                    Text(
                      'Kilometraje Inicial Ingresado: $_kmInicial',
                      style: const TextStyle(color: Colors.white),
                    ),
                  TextFormField(
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Kilometraje',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese un valor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_mileageController.text.isNotEmpty) {
                        final kmFinal = int.tryParse(_mileageController.text) ?? 0;
                        if (_kmInicial != null && kmFinal <= _kmInicial!) {
                          showError('El kilometraje final no puede ser menor o igual al kilometraje inicial ingresado.');
                        } else {
                          _showConfirmationDialog(kmFinal);
                        }
                      }
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(int kmFinal) {
    if (hasError) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 66, 68),
          title: const Text(
            '¿Está seguro de finalizar?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Esta acción cerrará su sesión',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _finalizeAndLogout(UserSession.motoristaId ?? 0, kmFinal, 'Finalizada');
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalizeAndLogout(int motoristaId, int kmFinal, String estado) async {
    final url = Uri.parse('$baseUrl/entregaenc/updateKmFinalAndStatus');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };
    final body = json.encode({
      'MotoristaId': motoristaId,
      'KmFinal': kmFinal,
      'Estado': estado,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      } else {
        showError('Error al finalizar: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> _checkAndShowMileageDialog() async {
    if (_showMileageDialog) {
      bool hasEntered = await hasEnteredCurrentMileage(UserSession.motoristaId ?? 0);
      if (!hasEntered && !hasError) {
        _showMilleageDialog();
      } else {
        setState(() {
          _showMileageDialog = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se permite regresar en esta pantalla'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      },
      child: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: const RouteSettings(name: '/entregas'),
          builder: (context) => Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Entregas'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
            drawer: const SideMenu(),
            body: Stack(
              children: [
                Opacity(
                  opacity: _showMileageDialog ? 0.2 : 1.0,
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : hasError
                        ? NoConnectionView(
                            onRetry: _fetchData,
                            message: errorMessage,
                          )
                        : items.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay entregas pendientes',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text('Orden: ${item.ordenCompraId}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Proveedor: ${item.proveedor}'),
                                        Text('Dirección: ${item.direccion}'),
                                        Text('Estado: ${item.estado}'),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EntregasDetallesView(items: [item]),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
            floatingActionButton: _showFinalizeButton ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isButtonExpanded ? 200.0 : 60.0,
              height: 60.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _isButtonExpanded = !_isButtonExpanded;
                  });
                  if (!_isButtonExpanded) {
                    _showFinalMileageDialog();
                  }
                },
                backgroundColor: const Color.fromARGB(255, 0, 66, 68),
                label: _isButtonExpanded
                    ? const Text('FINALIZAR')
                    : const Icon(Icons.check),
                icon: _isButtonExpanded ? const Icon(Icons.check) : null,
              ),
            ) : null,
          ),
        ),
      ),
    );
  }
}
