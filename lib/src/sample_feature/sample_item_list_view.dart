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
}

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

class _SampleItemListViewState extends State<SampleItemListView> {

  bool isLoading = false;
  bool _showMileageDialog = true;
  TextEditingController _mileageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RecolectaItem> items = [
    RecolectaItem(
      idRecolecta: 1,
      ordenCompraId: 12345,
      proveedor: 'Proveedor A',
      direccion: 'Calle 123, Ciudad',
      fechaRecolecta: DateTime.now(),
      horaRecolecta: '10:00 AM',
      fechaAsignacion: DateTime.now(),
      fechaAceptacion: DateTime.now(),
      motoristaId: 1,
      idVehiculo: 1,
      kmInicial: 100,
      kmFinal: 150,
      tiempoEnSitio: 30,
      evaluacionProveedor: 4,
      comentario: 'Todo bien',
      cantidad: 50,
      estado: 'aprobado',
      fechaRegistro: DateTime.now(),
      tc: 'TC123',
      tituloTC: 'Título TC',
    ),
    RecolectaItem(
      idRecolecta: 2,
      ordenCompraId: 67890,
      proveedor: 'Proveedor B',
      direccion: 'Avenida 456, Otra Ciudad',
      fechaRecolecta: DateTime.now(),
      horaRecolecta: '2:00 PM',
      fechaAsignacion: DateTime.now(),
      motoristaId: 2,
      idVehiculo: 2,
      kmInicial: 200,
      kmFinal: 250,
      tiempoEnSitio: 60,
      comentario: 'Hubo un retraso',
      cantidad: 100,
      estado: 'pendiente',
      fechaRegistro: DateTime.now(),
      tc: 'TC456',
      tituloTC: 'Título TC',
    ),
    RecolectaItem(
      idRecolecta: 2,
      ordenCompraId: 67890,
      proveedor: 'Proveedor C',
      direccion: 'Avenida 456, Otra Ciudad',
      fechaRecolecta: DateTime.now(),
      horaRecolecta: '2:00 PM',
      fechaAsignacion: DateTime.now(),
      motoristaId: 2,
      idVehiculo: 2,
      kmInicial: 200,
      kmFinal: 250,
      tiempoEnSitio: 60,
      comentario: 'Todo Listo',
      cantidad: 100,
      estado: 'rechazado',
      fechaRegistro: DateTime.now(),
      tc: 'TC456',
      tituloTC: 'Título TC',
    ),
  ];

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
