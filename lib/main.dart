import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_bloc.dart';
import 'package:recolectores_app_flutter/src/bloc/recolecta_details_bloc.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
  MultiBlocProvider(
      providers: [
        BlocProvider<RecolectaBloc>(
          create: (context) => RecolectaBloc(),
        ),
        BlocProvider<RecolectaDetailsBloc>(
          create: (context) => RecolectaDetailsBloc(),
        ),
      ],
      child: MyApp(settingsController: settingsController),
    ),
  );
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<RecolectaBloc>(
//           create: (context) => RecolectaBloc(),
//         ),
//         BlocProvider<RecolectaDetailsBloc>(
//           create: (context) => RecolectaDetailsBloc(),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Recolectores App',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const SampleItemListView(),
//       ),
//     );
//   }
// }