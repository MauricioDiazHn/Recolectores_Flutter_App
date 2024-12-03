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


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recolectores_app_flutter/models/rive_asset.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/src/sample_feature/sample_item_list_view.dart';

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

  @override
  void initState() {
    super.initState();
    _isApproved = widget.item.estado.toLowerCase() == 'aprobado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Detalle del Ítem'),
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
            _buildNonEditableField(label: 'Comentario', value: widget.item.comentario),
            _buildNonEditableField(
                label: 'Cantidad', value: widget.item.cantidad.toString()),
            const SizedBox(height: 20),
            _buildSwitchField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes implementar la lógica para guardar cambios
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cambios guardados exitosamente.'),
                  ),
                );
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
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade200,
            ),
            const SizedBox(width: 10),
            Text(
              _isApproved ? 'Aprobado' : 'Pendiente',
              style: TextStyle(
                color: _isApproved ? Colors.green : Colors.red,
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
