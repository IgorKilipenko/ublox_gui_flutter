import 'package:flutter/material.dart';
import 'package:ublox_gui_flutter/main.dart';
import 'package:ublox_gui_flutter/screens/debug_screen.dart';
import 'package:ublox_gui_flutter/screens/settings_screen.dart';

class ScreenRoutes {
  static Map<String, WidgetBuilder> get routes {
    return <String, WidgetBuilder>{
      SettingsScreen.routeName: (BuildContext context) => SettingsScreen(),
      DebugScreen.routeName: (BuildContext context) => DebugScreen(),
      UbxGuiApp.routeName: (BuildContext context) => UbxGuiApp(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case UbxGuiApp.routeName:
        return MaterialPageRoute(settings: settings, maintainState: true, builder: (context) => UbxGuiApp());
      case DebugScreen.routeName:
        return MaterialPageRoute(settings: settings, maintainState: true, builder: (context) => DebugScreen());
      case SettingsScreen.routeName:
        return MaterialPageRoute(settings: settings, maintainState: true, builder: (context) => SettingsScreen());
      default:
        return MaterialPageRoute(settings: settings, maintainState: true, builder: (context) => UbxGuiApp());
    }
  }

  static const String HOME = '/';
  static const String DEBUG = '/debug';
  static const String SETTINGS = '/setting';
}
