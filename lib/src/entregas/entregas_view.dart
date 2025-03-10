import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
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
    });
    await fetchItems();
    await checkMileageStatus();
  }

  Future<void> fetchItems() async {
    String? token = UserSession.token;
    int? motoristaId = UserSession.motoristaId;

    final url = Uri.parse('$baseUrl/entregaenc/$motoristaId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          items = data.map((item) => EntregaItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        showError('Error al cargar datos: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showError('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkMileageStatus() async {
    String? token = UserSession.token;
    int? motoristaId = UserSession.motoristaId;

    final url = Uri.parse('$baseUrl/entregaenc/kmstatus/$motoristaId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _showFinalizeButton = data['showFinalizeButton'] ?? true;
          _kmInicial = data['kmInicial'];
        });
      }
    } catch (e) {
      showError('Error al verificar estado de kilometraje: $e');
    }
  }

  void _showMilleageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 66, 68),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingrese el kilometraje actual',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_mileageController.text.isNotEmpty) {
                  await _submitMileage(int.parse(_mileageController.text));
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkAndShowMileageDialog() async {
    if (_showMileageDialog) {
      _showMilleageDialog();
      await UserSession.setMileageDialogShown();
    }
  }

  Future<void> _submitMileage(int mileage) async {
    String? token = UserSession.token;
    int? motoristaId = UserSession.motoristaId;

    final url = Uri.parse('$baseUrl/entregaenc/kminicial');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'motoristaId': motoristaId,
      'kmInicial': mileage,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          _kmInicial = mileage;
        });
      } else {
        showError('Error al enviar kilometraje: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> _submitFinalMileage(int mileage) async {
    String? token = UserSession.token;
    int? motoristaId = UserSession.motoristaId;

    final url = Uri.parse('$baseUrl/entregaenc/kmfinal');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'motoristaId': motoristaId,
      'kmFinal': mileage,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          _showFinalizeButton = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kilometraje final registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        showError('Error al enviar kilometraje final: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void _showFinalMileageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 66, 68),
          title: const Text('Finalizar Jornada',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingrese el kilometraje final',
                  style: TextStyle(color: Colors.white)),
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
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                if (_mileageController.text.isNotEmpty) {
                  _submitFinalMileage(int.parse(_mileageController.text));
                  Navigator.pop(context);
                }
              },
              child:
                  const Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Entregas'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_showFinalizeButton)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () {
                _mileageController.clear();
                _showFinalMileageDialog();
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('No hay entregas pendientes'))
              : ListView.builder(
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
    );
  }
}
