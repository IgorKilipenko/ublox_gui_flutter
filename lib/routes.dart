import 'package:flutter/material.dart';
import 'package:ublox_gui_flutter/screens/settings_screen.dart';

class ScreenRoutes {
  static Map<String, WidgetBuilder> get routes {
    return <String, WidgetBuilder> {
      SettingsScreen.routeName: (BuildContext context) => SettingsScreen(),
    };
  }
}