import 'package:rive/rive.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src, route;
  late SMIBool? input;

  RiveAsset(
    this.src, this.route, {
    required this.artboard,
    required this.stateMachineName,
    required this.title,
    this.input,
  });

  set setInput(SMIBool status) {
    input = status;
  }
}

List<RiveAsset> sideMenu = [
  RiveAsset("icons/animated_icon_set1_color.riv", "/",
      artboard: "HOME", stateMachineName: "HOME_interactivity", title: "Recolecta / Pedidos"),
  RiveAsset("icons/animated_icon_set1_color.riv", "/entregas",
      artboard: "TIMER", stateMachineName: "TIMER_Interactivity", title: "Entregas / Pedidos"),
  RiveAsset("icons/animated_icon_set1_color.riv", "login",
      artboard: "SEARCH", stateMachineName: "SEARCH_Interactivity", title: "Lista de Pedidos"),
  RiveAsset("icons/animated_icon_set1_color.riv", "/favorites",
      artboard: "LIKE/STAR", stateMachineName: "STAR_Interactivity", title: "Favorites"),
  RiveAsset("icons/animated_icon_set1_color.riv", "/help",
      artboard: "CHAT", stateMachineName: "CHAT_Interactivity", title: "Help"),
];

List<RiveAsset> sideMenu2 = [
  RiveAsset("icons/animated_icon_set1_color.riv", "/history",
      artboard: "TIMER", stateMachineName: "TIMER_Interactivity", title: "History"),
  RiveAsset("icons/animated_icon_set1_color.riv", "/notification",
      artboard: "BELL", stateMachineName: "BELL_Interactivity", title: "Notification"),
];