import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';
import 'package:recolectores_app_flutter/components/no_connection_view.dart';
import 'package:recolectores_app_flutter/src/services/UserSession.dart';
import 'package:recolectores_app_flutter/src/services/secure_storage_service.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'dart:async';
import 'recolectas_detalles_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'api_constants.dart';

/// Displays a list of SampleItems.
class RecolectasView extends StatefulWidget {
  const RecolectasView({
    super.key,
  });

  static const routeName = '/';

  @override
  State<RecolectasView> createState() => _RecolectasViewState();
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

class _RecolectasViewState extends State<RecolectasView> with WidgetsBindingObserver {
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  bool _needsKmInicial = true;
  bool _shouldShowMileageDialog = false;
  TextEditingController _mileageController = TextEditingController();
  bool _isButtonExpanded = false;
  bool _showFinalizeButton = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _kmInicial;
  List<RecolectaItem> items = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKmInicialAndSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mileageController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check session when app comes to foreground
      _checkSessionAndFetchData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSessionAndFetchData(); // Check session when returning to view
  }

  Future<void> _checkKmInicialAndSession() async {
    if (!mounted) return;
    
    final secureStorage = SecureStorageService();
    final isValid = await secureStorage.isSessionValid();
    
    if (!isValid) {
      _handleUnauthorized();
      return;
    }

    bool hasCurrentMileage = await hasEnteredCurrentMileage(UserSession.motoristaId ?? 0);
    setState(() {
      _needsKmInicial = !hasCurrentMileage;
    });

    if (!_needsKmInicial) {
      _fetchData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _displayMileageDialog();
      });
    }
  }

  Future<void> _checkSessionAndFetchData() async {
    if (!mounted) return;
    
    final secureStorage = SecureStorageService();
    final isValid = await secureStorage.isSessionValid();
    if (!isValid && mounted) {
      _handleUnauthorized();
    } else {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      await fetchItems();
      if (!hasError) {
        await checkMileageStatus();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error al cargar los datos. Por favor, intente de nuevo.';
      });
    }
  }

  Future<void> fetchItems() async {
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
          hasError = false;
          errorMessage = '';
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Error al cargar los datos. Por favor, intente de nuevo.';
        });
        return;
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
      });
      return;
    }
  }

  void _displayMileageDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 0, 66, 68),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingrese el kilometraje inicial',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Kilometraje',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_mileageController.text.isEmpty) {
                      showError('Debe ingresar un kilometraje válido');
                      return;
                    }
                    final kmInicial = int.tryParse(_mileageController.text);
                    if (kmInicial == null || kmInicial <= 0) {
                      showError('Ingrese un kilometraje válido mayor a 0');
                      return;
                    }
                    _submitKmInicial(UserSession.motoristaId ?? 0, kmInicial, 'En Ruta');
                    setState(() {
                      _needsKmInicial = false;
                    });
                    Navigator.of(context).pop();
                    _fetchData();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitKmInicial(int motoristaId, int kmInicial, String estado) async {
    final url = Uri.parse('$baseUrl/recolectaenc/updateKmInicialAndStatus');
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
        setState(() {
          hasError = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al actualizar el kilometraje. Por favor, intente de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado al actualizar el kilometraje. Por favor, intente de nuevo.';
        }
      });
    }
  }

  void _showFinalizeDialog() async {
    await _fetchKmInicial();
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
                          Navigator.of(context).pop(); // Cierra el diálogo
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
                        'KmInicial Ingresado: $_kmInicial',
                        style: const TextStyle(color: Colors.white),
                      ),
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

  Future<void> _fetchKmInicial() async {
    final url = Uri.parse('$baseUrl/recolectaenc/${UserSession.motoristaId}/currentKmInicial');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _kmInicial = data ?? 0;
          hasError = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al obtener el kilometraje inicial. Por favor, intente de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado al obtener el kilometraje. Por favor, intente de nuevo.';
        }
      });
    }
  }

  void _showConfirmationDialog(int kmFinal) {
    Navigator.of(context).pop(); // Cerrar el diálogo actual
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de que desea finalizar?, no hay vuelta atras'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                // Aquí puedes llamar a la función para cerrar sesión
                _finalizeAndLogout(UserSession.motoristaId ?? 0, kmFinal, 'Recolectada');
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalizeAndLogout(int motoristaId, int kmFinal, String estado) async {
    final url = Uri.parse('$baseUrl/recolectaenc/updateKmFinalAndStatus');
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
        setState(() {
          hasError = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al finalizar la sesión. Por favor, intente de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado al finalizar. Por favor, intente de nuevo.';
        }
      });
    }
  }

  Future<bool> hasEnteredCurrentMileage(int motoristaId) async {
    final url = Uri.parse('$baseUrl/recolectaenc/$motoristaId/currentMileage?checkFinalMileage=false');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          _shouldShowMileageDialog = response.body == 'true';
          hasError = false;
          errorMessage = '';
        });
        return response.body == 'true';
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al verificar el estado del kilometraje. Por favor, intente de nuevo.';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado al verificar el kilometraje. Por favor, intente de nuevo.';
        }
      });
      return false;
    }
  }

  Future<bool> hasFinalizedRecolecta(int motoristaId) async {
    final url = Uri.parse('$baseUrl/recolectaenc/$motoristaId/currentMileage?checkFinalMileage=true');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          _showFinalizeButton = response.body == 'true';
          hasError = false;
          errorMessage = '';
        });
        return response.body == 'true';
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error al verificar el estado de la recolecta. Por favor, intente de nuevo.';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado al verificar la recolecta. Por favor, intente de nuevo.';
        }
      });
      return false;
    }
  }

  Future<void> checkMileageStatus() async {
    int motoristaId = UserSession.motoristaId ?? 0;

    bool hasCurrentMileage = await hasEnteredCurrentMileage(motoristaId);
    bool hasFinalized = await hasFinalizedRecolecta(motoristaId);

    setState(() {
      _shouldShowMileageDialog = !hasCurrentMileage;
      _showFinalizeButton = !hasFinalized;
    });
  }

  Future<void> _checkAndShowMileageDialog() async {
    await checkMileageStatus();
    if (_shouldShowMileageDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _displayMileageDialog();
      });
    }
  }

  Future<void> _updateMotoristaData() async {
    final url = Uri.parse('$baseUrl/recolectaenc/UpdateByMotoristaId/${UserSession.motoristaId}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };

    try {
      final response = await http.put(url, headers: headers);
      if (response.statusCode != 200) {
        setState(() {
          hasError = true;
          errorMessage = 'Error al actualizar datos del motorista. Por favor, intente de nuevo.';
        });
      } else {
        setState(() {
          hasError = false;
          errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        if (e is SocketException) {
          errorMessage = 'No hay conexión a internet. Por favor, verifique su conexión y vuelva a intentar.';
        } else {
          errorMessage = 'Ocurrió un error inesperado al actualizar datos del motorista. Por favor, intente de nuevo.';
        }
      });
    }
  }

  Future<void> _refreshData() async {
    await _checkSessionAndFetchData(); // Verify session when refreshing
    if (mounted) {
      await _updateMotoristaData();
      await _checkAndShowMileageDialog();
    }
  }

  void _handleUnauthorized() async {
    // Limpiar el almacenamiento seguro
    final secureStorage = SecureStorageService();
    await secureStorage.clearAll();
    
    // Limpiar la sesión
    UserSession.token = null;
    UserSession.motoristaId = null;
    UserSession.hasShownMileageDialog = false;

    if (mounted) {
      // Navegar al login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Login(),
          settings: const RouteSettings(name: '/login'),
        ),
        (route) => false,
      );
    }
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
    return WillPopScope(
      onWillPop: () async {
        // En la vista principal, permitir salir de la app
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
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
        body: Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isLoading ? 0.5 : 1.0,
              child: _buildMainContent(),
            ),
            if (_shouldShowMileageDialog)
              Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
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
                _showFinalizeDialog();
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
    );
  }
  
  // Modificar _buildMainContent para bloquear contenido sin km inicial
  Widget _buildMainContent() {
    if (_needsKmInicial) {
      return const Center(
        child: Text(
          'Debe ingresar el kilometraje inicial para continuar',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (hasError) {
      return NoConnectionView(
        onRetry: _fetchData,
        message: errorMessage,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color.fromARGB(255, 0, 66, 68), 
      backgroundColor: Colors.white, 
      strokeWidth: 3.0,
      displacement: 40.0, 
      child: items.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes recolectas pendientes',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Desliza hacia abajo para actualizar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Icon(
                        Icons.arrow_downward,
                        size: 24,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: _buildProviderList(),
            ),
    );
  }

  List<Widget> _buildProviderList() {
    Map<String, List<RecolectaItem>> providerMap = {};
    for (var item in items) {
      if (!providerMap.containsKey(item.proveedor)) {
        providerMap[item.proveedor] = [];
      }
      providerMap[item.proveedor]!.add(item);
    }

    List<Widget> widgets = [];
    providerMap.forEach((proveedor, proveedorItems) {
      // Verificar el estado de todas las órdenes del proveedor
      bool todasRecolectadas = proveedorItems.every(
        (item) => item.estado.toLowerCase() == 'recolectada'
      );
      bool algunaEnRuta = proveedorItems.any(
        (item) => item.estado.toLowerCase() == 'en ruta'
      );
      bool algunaFallida = proveedorItems.any(
        (item) => ['incompleta', 'fallida'].contains(item.estado.toLowerCase())
      );
      
      // Verificar si hay órdenes nuevas o pendientes
      bool hayOrdenesNuevas = proveedorItems.any((item) => 
        !['recolectada', 'incompleta', 'fallida'].contains(item.estado.toLowerCase())
      );

      // Determinar el color basado en los estados
      Color backgroundColor;
      Color borderColor;
      Color textColor;

      if (todasRecolectadas) {
        backgroundColor = Colors.greenAccent.withOpacity(0.2);
        borderColor = Colors.green;
        textColor = const Color.fromARGB(255, 139, 187, 142);
      } else if (algunaFallida && !hayOrdenesNuevas) {
        // Solo mostrar rojo si hay fallidas y no hay nuevas órdenes
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
        textColor = const Color.fromARGB(255, 187, 139, 139);
      } else if (algunaEnRuta || hayOrdenesNuevas || !todasRecolectadas) {
        backgroundColor = Colors.yellow.withOpacity(0.2);
        borderColor = Colors.yellow.shade700;
        textColor = const Color.fromARGB(255, 202, 201, 110);
      } else {
        backgroundColor = Colors.transparent;
        borderColor = Colors.black54;
        textColor = const Color.fromARGB(240, 255, 255, 255);
      }

      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              'Proveedor: $proveedor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            subtitle: Text('Total de Órdenes: ${proveedorItems.length}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecolectasDetallesView(items: proveedorItems),
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