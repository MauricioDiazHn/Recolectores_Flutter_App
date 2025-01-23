import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_details_bloc.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_details_event.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_details_state.dart';
import 'package:recolectores_app_flutter/src/models/recolecta_item.dart';
import 'package:flutter/services.dart';

class SampleItemDetailsView extends StatefulWidget {
  final List<RecolectaItem> items;

  const SampleItemDetailsView({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  late TextEditingController comentarioController;

  @override
  void initState() {
    super.initState();
    comentarioController = TextEditingController();
    context.read<RecolectaDetailsBloc>().add(FetchOrderData(items: widget.items));
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Detalles del Pedido'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: BlocBuilder<RecolectaDetailsBloc, RecolectaDetailsState>(
        builder: (context, state) {
          if (state is RecolectaDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecolectaDetailsLoaded) {
            return Padding(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildOrderDetails(state),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: () {
                      context.read<RecolectaDetailsBloc>().add(
                        SubmitOrderData(
                          items: widget.items,
                          cantidadesRecogidas: state.cantidadesRecogidas,
                          comentario: comentarioController.text,
                          isApproved: state.isApprovedMap.values.any((approved) => approved),
                        ),
                      );
                    },
                    child: const Icon(Icons.save),
                  ),
                ],
              ),
            );
          } else if (state is RecolectaDetailsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No hay datos disponibles.'));
          }
        },
      ),
    );
  }

  List<Widget> _buildOrderDetails(RecolectaDetailsLoaded state) {
    if (state.orderData.isEmpty) {
      return [const Text('No hay datos disponibles.')];
    }

    List<Widget> widgets = [];

    // Agrupar productos por orden de compra
    Map<int, List<dynamic>> ordersMap = {};
    for (var item in state.orderData) {
      if (!ordersMap.containsKey(item['orden'])) {
        ordersMap[item['orden']] = [];
      }
      ordersMap[item['orden']]!.addAll(item['productos']);
    }

    // Crear widgets basados en los grupos de órdenes de compra
    ordersMap.forEach((orden, productos) {
      String? nombreProyecto = state.orderData.firstWhere((data) => data['orden'] == orden)['nombreProyecto'];
      widgets.add(
        Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Orden: #$orden\nCant: ${productos.fold<int>(0, (int sum, item) => sum + (item['cantidad'] as int))}'),
                _buildSwitchField(orden, state),
              ],
            ),
            subtitle: state.showDetailsMap[orden] ?? false
                ? Column(
                    children: _buildProductDetailsWithInputs(productos, orden, state),
                  )
                : null,
            onTap: () {
              setState(() {
                state.showDetailsMap[orden] = !(state.showDetailsMap[orden] ?? false);
              });
            },
          ),
        ),
      );
    });

    return widgets;
  }

  List<Widget> _buildProductDetailsWithInputs(List<dynamic> productos, int orden, RecolectaDetailsLoaded state) {
    return productos.map<Widget>((producto) {
      String productName = producto['nombre'];
      int? cantidad = state.cantidadesRecogidas[orden]?[productName];
      return Row(
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
                  'Cantidad: ${producto['cantidad']}',
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
              initialValue: (cantidad != null && cantidad > 0) ? cantidad.toString() : producto['cantidad'].toString(),
              onChanged: (value) {
                setState(() {
                  state.cantidadesRecogidas[orden]![productName] = int.tryParse(value) ?? 0;
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

  Widget _buildSwitchField(int orden, RecolectaDetailsLoaded state) {
    return Row(
      children: [
        Switch(
          value: state.isApprovedMap[orden] ?? false,
          onChanged: (value) {
            setState(() {
              state.isApprovedMap[orden] = value;
            });
          },
          activeColor: Colors.green.withOpacity(0.8),
          inactiveThumbColor: Colors.yellow.withOpacity(0.8),
          inactiveTrackColor: Colors.yellow.shade200,
        ),
        const SizedBox(width: 10),
        Text(
          (state.isApprovedMap[orden] ?? false) ? 'Completo' : 'Parcial',
          style: TextStyle(
            color: (state.isApprovedMap[orden] ?? false) ? Colors.green : Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        maxLines: 3,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}