import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ublox_gui_flutter/components/drawer.dart';
import 'package:ublox_gui_flutter/components/map.dart';
import 'package:ublox_gui_flutter/components/receiver.dart';
import 'package:ublox_gui_flutter/model/ubx_tcp_listener.dart';
import 'package:ublox_gui_flutter/native_add.dart';
import 'package:ublox_gui_flutter/routes.dart';
import 'package:ublox_gui_flutter/screens/state/ui_state.dart';
import 'package:ublox_gui_flutter/ublox/ubx_decoder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UbxGuiApp(),
      routes: ScreenRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.blue))));
}

class UbxGuiApp extends StatelessWidget {
  final UbxTcpListener _ubxTcpListener = UbxTcpListener();
  @override
  Widget build(BuildContext context) {
    print('Native FFI 2 + 5 = ${nativeAdd(2,5)}');
    final mediaQueue = MediaQuery.of(context);
    //final theme = Theme.of(context);
    return MultiProvider(
        //                                     <--- MultiProvider
        providers: [
          ChangeNotifierProvider<UbxTcpListener>.value(
            value: _ubxTcpListener,
          ),
          //create: (context) => UbxTcpListener()),
          ChangeNotifierProvider<UiState>(create: (context) => UiState())
        ],
        child: Scaffold(
          appBar: AppBar(title: Text('Ubx GUI FLUTTER')),
          drawer: AppDrawer(),
          body: Stack(
            //mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.topCenter,
                  height: mediaQueue.size.height,
                  margin: new EdgeInsets.all(0.0),
                  width: mediaQueue.size.width,
                  child: MapStreamWidget(stream: _ubxTcpListener.pvtMessageStream)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(child: ReceiverPaneWidget()),
                height: 100,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: StreamBuilder<PvtMessage>(
                  stream: _ubxTcpListener.pvtMessageStream,
                  builder: (context, snapshot) {
                    return Column(
                      children: <Widget>[
                        Text('${snapshot.hasData ? snapshot.data.latitude : 'NULL'}'),
                      ],
                    );
                  }
                ),
              )
            ],
          ),
        ));
  }
}
