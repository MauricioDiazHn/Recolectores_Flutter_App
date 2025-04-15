import 'package:flutter/material.dart';
import 'package:recolectores_app_flutter/components/info_card.dart';
import 'package:recolectores_app_flutter/components/side_menu_tile.dart';
import 'package:recolectores_app_flutter/models/rive_asset.dart';
import 'package:recolectores_app_flutter/src/entregas/entregas_view.dart';
import 'package:recolectores_app_flutter/src/services/UserSession.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'package:recolectores_app_flutter/utils/rive_utils.dart';
import 'package:rive/rive.dart';
import 'package:recolectores_app_flutter/src/recolectas/recolectas_view.dart';
import 'package:recolectores_app_flutter/src/help/help_view.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  RiveAsset selectedMenu = sideMenu.first;

  void _updateSelectedMenu() {
    final route = ModalRoute.of(context)?.settings.name ?? '/';
    setState(() {
      selectedMenu = sideMenu.firstWhere(
        (menu) => menu.route == route,
        orElse: () => sideMenu.first,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedMenu();
  }

  // Método para manejar la navegación a una pantalla específica
  void navigateTo(String route) {
    if (route == "/") {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const RecolectasView(),
            settings: const RouteSettings(name: '/'),
          ),
          (route) => false,
        );
      });
    } else if (route == "/entregas") {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const EntregasView(),
            settings: const RouteSettings(name: '/entregas'),
          ),
          (route) => false,
        );
      });
    } else if (route == "/help") {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HelpView(),
            settings: const RouteSettings(name: '/help'),
          ),
          (route) => false,
        );
      });
    } else {
      // Mostrar mensaje de funcionalidad no disponible
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta funcionalidad aún no está disponible'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Redirigir a RecolectasView después de un breve delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const RecolectasView(),
            settings: const RouteSettings(name: '/'),
          ),
          (route) => false,
        );
      });
    }
  }
  
  Future<void> logout() async {
  await UserSession.clearSession();
  if (mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color.fromARGB(15, 20, 219, 226),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                name: UserSession.fullName,
                profession: UserSession.userName,
                versionApp: "v1.5",
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenu.map(
                (menu) => SideMenuTile(
                  menu: menu,
                  riveonInit: (artboard) {
                    StateMachineController controller =
                        RiveUtils.getRiveController(artboard,
                            stateMachineName: menu.stateMachineName);
                    menu.input = controller.findSMI("active") as SMIBool;
                  },
                  press: () {
                    menu.input!.change(true);

                    Future.delayed(const Duration(seconds: 1), () {
                      menu.input!.change(false);
                    });
                    setState(() {
                      selectedMenu = menu;
                    });

                    // Llamar al método de navegación
                    navigateTo(menu.route);
                  },
                  isActive: selectedMenu == menu,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "History".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenu2.map(
                (menu) => SideMenuTile(
                  menu: menu,
                  riveonInit: (artboard) {
                    StateMachineController controller =
                        RiveUtils.getRiveController(artboard,
                            stateMachineName: menu.stateMachineName);
                    menu.input = controller.findSMI("active") as SMIBool;
                  },
                  press: () {
                    menu.input!.change(true);

                    Future.delayed(const Duration(seconds: 1), () {
                      menu.input!.change(false);
                    });
                    setState(() {
                      selectedMenu = menu;
                    });

                    // Llamar al método de navegación
                    navigateTo(menu.route);
                  },
                  isActive: selectedMenu == menu,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    logout(); // Llamar al método de logout
                  },
                  child: Text(
                    "Cerrar Sesión".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
