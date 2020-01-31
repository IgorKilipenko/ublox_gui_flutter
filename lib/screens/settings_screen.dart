import 'package:flutter/material.dart';
import 'package:ublox_gui_flutter/routes.dart';
import 'package:ublox_gui_flutter/screens/screen_arguments.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = ScreenRoutes.SETTINGS;

  @override
  Widget build(BuildContext context) {
    //final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    print('Settings screen build');
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
          child: Center(
        child: Text("Settings Screen"),
      )),
    );
  }
}