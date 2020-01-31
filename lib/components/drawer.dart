import 'package:flutter/material.dart';
import 'package:ublox_gui_flutter/routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              child: Container(
                decoration: BoxDecoration(color: theme.primaryColor),
                child: Center(child: Text('HEADER')),
              )),
          ListTile(
            title: Text('Home'),
            onTap: () {
              navigator.pushNamed(ScreenRoutes.HOME);
            },
          ),
          ListTile(
            title: Text('Debug'),
            onTap: () {
              navigator.pushNamed(ScreenRoutes.DEBUG);
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              navigator.pushNamed(ScreenRoutes.SETTINGS);
            },
          ),
        ],
      ),
    );
  }
}
