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

class SampleItemDetailsView extends StatefulWidget {
  final RecolectaItem item;

  const SampleItemDetailsView({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<SampleItemDetailsView> createState() =>
      _RecolectaItemDetailsViewState();
}

class _RecolectaItemDetailsViewState extends State<SampleItemDetailsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late bool _isApproved;
  late TextEditingController comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isApproved = widget.item.estado.toLowerCase() == 'aprobado';
    comentarioController = TextEditingController(text: widget.item.comentario);
  }

  @override
  void dispose() {
    comentarioController.dispose(); // Limpiamos el controlador cuando el widget se destruya
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
            _buildEditableField(label: 'Comentario',
              controller: comentarioController),
            _buildNonEditableField(
                label: 'Cantidad', value: widget.item.cantidad.toString()),
            const SizedBox(height: 20),
            _buildSwitchField(),
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

  Widget _buildSwitchField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Estado',
          style: TextStyle(fontSize: 16.0),
        ),
        Row(
          children: [
            Switch(
              value: _isApproved,
              onChanged: (value) {
                setState(() {
                  _isApproved = value;
                });
              },
              activeColor: Colors.green.withOpacity(0.8),
              inactiveThumbColor: Colors.yellow.withOpacity(0.8),
              inactiveTrackColor: Colors.yellow.shade200,
            ),
            const SizedBox(width: 10),
            Text(
              _isApproved ? 'Aprobado' : 'Pendiente',
              style: TextStyle(
                color: _isApproved ? Colors.green : Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate() // Usamos `flutter_animate` aquí
                .fade(duration: 300.ms) // Animación de desvanecimiento
                .scale(delay: 100.ms), // Animación de escalado para suavidad
          ],
        ),
      ],
    );
  }
}
