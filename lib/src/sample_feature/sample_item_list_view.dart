import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/models/rive_asset.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'api_constants.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}


class RecolectaItem {
  final int idRecolecta;
  final int ordenCompraId;
  final String proveedor;
  final String direccion;
  final DateTime fechaRecolecta;
  final String horaRecolecta;
  final DateTime? fechaAsignacion;
  final DateTime? fechaAceptacion;
  final int motoristaId;
  final int idVehiculo;
  final int kmInicial;
  final int kmFinal;
  final int? tiempoEnSitio;
  final int? evaluacionProveedor;
  final String comentario;
  final int cantidad;
  final String estado;
  final DateTime fechaRegistro;
  final String tc;
  final String tituloTC;

  RecolectaItem({
    required this.idRecolecta,
    required this.ordenCompraId,
    required this.proveedor,
    required this.direccion,
    required this.fechaRecolecta,
    required this.horaRecolecta,
    this.fechaAsignacion,
    this.fechaAceptacion,
    required this.motoristaId,
    required this.idVehiculo,
    required this.kmInicial,
    required this.kmFinal,
    this.tiempoEnSitio,
    this.evaluacionProveedor,
    required this.comentario,
    required this.cantidad,
    required this.estado,
    required this.fechaRegistro,
    required this.tc,
    required this.tituloTC,
  });

  factory RecolectaItem.fromJson(Map<String, dynamic> json) {
    return RecolectaItem(
      idRecolecta: json['idlinea'] ?? 0, // Valor por defecto si es null
      ordenCompraId: json['ordenCompraId'] ?? 0, // Valor por defecto si es null
      proveedor: json['proveedor'] ?? '', // Valor por defecto si es null
      direccion: json['direccion'] ?? '', // Valor por defecto si es null
      fechaRecolecta: json['fechaRecolecta'] != null
          ? DateTime.parse(json['fechaRecolecta'])
          : DateTime.now(), // Valor por defecto si es null
      horaRecolecta:
          json['horaRecolecta'] ?? '', // Valor por defecto si es null
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : null, // Valor por defecto si es null
      fechaAceptacion: json['fechaAceptacion'] != null
          ? DateTime.parse(json['fechaAceptacion'])
          : null, // Valor por defecto si es null
      motoristaId: json['motoristaId'] ?? 0, // Valor por defecto si es null
      idVehiculo: json['idVehiculo'] ?? 0, // Valor por defecto si es null
      kmInicial: json['kmInicial'] ?? 0, // Valor por defecto si es null
      kmFinal: json['kmFinal'] ?? 0, // Valor por defecto si es null
      tiempoEnSitio: json['tiempoEnSitio'] ?? 0, // Valor por defecto si es null
      evaluacionProveedor:
          json['evaluacionProveedor'] ?? 0, // Valor por defecto si es null
      comentario: json['comentario'] ?? '', // Valor por defecto si es null
      cantidad: json['cantidad'] ?? 0, // Valor por defecto si es null
      estado: json['estado'] ?? '', // Valor por defecto si es null
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(), // Valor por defecto si es null
      tc: json['tc'] ?? '', // Valor por defecto si es null
      tituloTC: json['tituloTC'] ?? '', // Valor por defecto si es null
    );
  }
}

class _SampleItemListViewState extends State<SampleItemListView> {

  
  bool isLoading = false;
  bool _showMileageDialog = true;
  TextEditingController _mileageController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RecolectaItem> items = [];

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
    fetchItems();
  }

  Future<void> fetchItems() async {
    // final prefs = await SharedPreferences.getInstance();

    // Recuperar el token
    // String? token = prefs.getString('token');
    String? token = UserSession.token;
    int? motoristaId = UserSession.motoristaId;

    final url = Uri.parse('$baseUrl/recolectaenc/$motoristaId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          items = data.map((item) => RecolectaItem.fromJson(item)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Agregado para manejar el menú lateral
      appBar: AppBar(
        title: const Text('Recolectas / Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Abre el menú lateral
          },
        ),
      ),
      drawer: const SideMenu(), // Aquí va el menú lateral
      body: Stack(
        children: [
          Opacity(
      opacity: _showMileageDialog ? 0.2 : 1.0, // Opacidad variable
      child: _buildMainContent(),
    ),
          if (_showMileageDialog)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ingrese el kilometraje actual'),
                      TextFormField(
                        controller: _mileageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(hintText: 'Kilometraje'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un valor';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_mileageController.text.isNotEmpty) {
                            setState(() {
                              _showMileageDialog = false;
                            });
                            int kilometraje = int.parse(_mileageController.text);
                            print("Kilometraje ingresado: $kilometraje");
                          }
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildMainContent() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : items.isEmpty
            ? const Center(child: Text('No hay datos disponibles.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: item.estado.toLowerCase() == 'aprobado'
                          ? Colors.greenAccent.withOpacity(0.2)
                          : item.estado.toLowerCase() == 'pendiente'
                              ? Colors.yellow.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.estado.toLowerCase() == 'aprobado'
                            ? Colors.green
                            : item.estado.toLowerCase() == 'pendiente'
                                ? Colors.yellow.shade700
                                : Colors.black54,
                        width: 2,
  ),
),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        'Proveedor: ${item.proveedor}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.estado.toLowerCase() == 'aprobado'
                              ? const Color.fromARGB(255, 139, 187, 142)
                              : item.estado.toLowerCase() == 'pendiente'
                                  ? const Color.fromARGB(255, 202, 201, 110)
                                  : const Color.fromARGB(240, 255, 255, 255),
                        ),
                      ),
                      subtitle: Text('Dirección: ${item.direccion}\nOrden: ${item.ordenCompraId}'),
                      trailing: Text('Cantidad: ${item.cantidad}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SampleItemDetailsView(item: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
  }
}
