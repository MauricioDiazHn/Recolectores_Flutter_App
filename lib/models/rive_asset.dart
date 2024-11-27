import 'package:rive/rive.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  late SMIBool? input;

  RiveAsset(
    this.src, {
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
  RiveAsset("icons/animated_icon_set1_color.riv",
      artboard: "HOME", stateMachineName: "HOME_interactivity", title: "Home"),
      RiveAsset("icons/animated_icon_set1_color.riv",
      artboard: "SEARCH", stateMachineName: "SEARCH_Interactivity", title: "Search"),
      RiveAsset("icons/animated_icon_set1_color.riv",
      artboard: "LIKE/STAR", stateMachineName: "STAR_Interactivity", title: "Favorites"),
      RiveAsset("icons/animated_icon_set1_color.riv",
      artboard: "CHAT", stateMachineName: "CHAT_Interactivity", title: "Help"),
];

List<RiveAsset> sideMenu2 = [
  RiveAsset("icons/animated_icon_set1_color.riv",
      artboard: "TIMER", stateMachineName: "TIMER_Interactivity", title: "History"),
      RiveAsset("icons/animated_icon_set1_color.riv",
      artboard: "BELL", stateMachineName: "BELL_Interactivity", title: "Notification"),
];