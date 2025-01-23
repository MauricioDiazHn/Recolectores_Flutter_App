import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_bloc.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_event.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_state.dart';
import 'package:recolectores_app_flutter/src/models/rive_asset.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import '../models/recolecta_item.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';
import 'package:rive/rive.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showMileageDialog = !UserSession.hasShownMileageDialog;
  TextEditingController _mileageController = TextEditingController();
  bool _isButtonExpanded = false;
  bool _showFinalizeButton = true;

  @override
  void initState() {
    super.initState();
    _checkAndShowMileageDialog();
    _fetchInitialData();
  }

  void _checkAndShowMileageDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showMileageDialog) {
        _showMilleageDialog();
      }
    });
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
              const Text('Ingrese el kilometraje actual', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
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
                    final kmInicial = int.tryParse(_mileageController.text) ?? 0;
                    context.read<RecolectaBloc>().add(
                      SubmitKmInicial(
                        motoristaId: UserSession.motoristaId ?? 0,
                        kmInicial: kmInicial,
                        estado: 'En Ruta',
                      ),
                    );
                    setState(() {
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

  void _showFinalizeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 66, 68),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingrese el kilometraje final', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
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
                    _showConfirmationDialog(kmFinal);
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

  void _showConfirmationDialog(int kmFinal) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de que desea finalizar y cerrar sesión?'),
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
                context.read<RecolectaBloc>().add(
                  SubmitKmFinal(
                    motoristaId: UserSession.motoristaId ?? 0,
                    kmFinal: kmFinal,
                    estado: 'Recolectada',
                  ),
                );
                setState(() {
                  _showFinalizeButton = false;
                });
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _refreshData() async {
    context.read<RecolectaBloc>().add(
      FetchItems(
        motoristaId: UserSession.motoristaId ?? 0,
        token: UserSession.token ?? '',
      ),
    );
  }

  void _fetchInitialData() {
    context.read<RecolectaBloc>().add(
      FetchItems(
        motoristaId: UserSession.motoristaId ?? 0,
        token: UserSession.token ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Recolectas / Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const SideMenu(),
      body: BlocBuilder<RecolectaBloc, RecolectaState>(
        builder: (context, state) {
          if (state is RecolectaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecolectaLoaded) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildMainContent(state.items),
            );
          } else if (state is RecolectaError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No hay datos disponibles.'));
          }
        },
      ),
      floatingActionButton: _showFinalizeButton
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isButtonExpanded ? 200.0 : 60.0,
              height: 60.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _isButtonExpanded = !_isButtonExpanded;
                  });
                  if (!_isButtonExpanded) {
                    _showFinalizeDialog();
                  }
                },
                backgroundColor: const Color.fromARGB(255, 0, 66, 68),
                label: _isButtonExpanded ? const Text('FINALIZAR') : const Icon(Icons.check),
                icon: _isButtonExpanded ? const Icon(Icons.check) : null,
              ),
            )
          : null,
    );
  }

  Widget _buildMainContent(List<RecolectaItem> items) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : items.isEmpty
            ? const Center(child: Text('No hay datos disponibles.'))
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: _buildProviderList(),
              );
  }

  List<Widget> _buildProviderList(List<RecolectaItem> items) {
    Map<String, List<RecolectaItem>> providerMap = {};
    for (var item in items) {
      if (!providerMap.containsKey(item.proveedor)) {
        providerMap[item.proveedor] = [];
      }
      providerMap[item.proveedor]!.add(item);
    }

    List<Widget> widgets = [];
    providerMap.forEach((proveedor, items) {
      widgets.add(
        Card(
          child: ListTile(
            title: Text(
              'Proveedor: $proveedor',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Total de Órdenes: ${items.length}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SampleItemDetailsView(items: items),
                ),
              );
            },
          ),
        ),
      );
    });

    return widgets;
  }
}