import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ublox_gui_flutter/components/drawer.dart';
import 'package:ublox_gui_flutter/components/map.dart';
import 'package:ublox_gui_flutter/components/receiver.dart';
import 'package:ublox_gui_flutter/model/ubx_tcp_listener.dart';
import 'package:ublox_gui_flutter/routes.dart';
import 'package:ublox_gui_flutter/screens/state/ui_state.dart';
import 'package:ublox_gui_flutter/model/ublox/ubx_decoder.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: UbxGuiApp(),
      initialRoute: ScreenRoutes.DEBUG,
      //routes: ScreenRoutes.routes,
      onGenerateRoute: ScreenRoutes.generateRoute,
      theme: ThemeData(primarySwatch: Colors.blue))));
}

class UbxGuiApp extends StatelessWidget {
  static const String routeName = ScreenRoutes.HOME;
  static final UbxTcpListener _ubxTcpListener = UbxTcpListener();
  static final UiState _uiState = UiState();

  Future<Map<PermissionGroup, PermissionStatus>> _requestPermissions() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.locationAlways]);
    print('permissions ${permissions?.toString()}');
    return permissions;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueue = MediaQuery.of(context);
    //final theme = Theme.of(context);
    return MultiProvider(
        //                                     <--- MultiProvider
        providers: [
          ChangeNotifierProvider<UbxTcpListener>.value(
            value: _ubxTcpListener,
          ),
          //create: (context) => UbxTcpListener()),
          ChangeNotifierProvider<UiState>.value(
            value: _uiState,
          )
        ],
        child: FutureBuilder<Map<PermissionGroup, PermissionStatus>>(
            future: _requestPermissions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null ) return CircularProgressIndicator();
              return UbxGuiAppWidget(
                  mediaQueue: mediaQueue, ubxTcpListener: _ubxTcpListener);
            }));
  }
}

class UbxGuiAppWidget extends StatelessWidget {
  const UbxGuiAppWidget({
    Key key,
    @required this.mediaQueue,
    @required UbxTcpListener ubxTcpListener,
  })  : _ubxTcpListener = ubxTcpListener,
        super(key: key);

  final MediaQueryData mediaQueue;
  final UbxTcpListener _ubxTcpListener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Text(
                          '${snapshot.hasData ? snapshot.data.latitude : 'NULL'}'),
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }
}
