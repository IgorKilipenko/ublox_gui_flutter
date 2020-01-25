import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
        ],
      ),
    );
  }
}
