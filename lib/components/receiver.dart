import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ublox_gui_flutter/model/ubx_tcp_listener.dart';
import 'package:ublox_gui_flutter/ublox/ubx_decoder.dart';

class ReceiverPaneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
      child: ListTile(
          leading: RecieverFloatingActionButton(),
          title: Container(
            child: PositionStreamWidget(),
          ),
          trailing: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'TEST',
                      child: Text('Working a lot harder'),
                    )
                  ])),
    );
  }
}


class PositionStreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UbxTcpListener ubxTcp =
        Provider.of<UbxTcpListener>(context, listen: false);
    //final theme = Theme.of(context);
    return StreamBuilder<PvtMessage>(
      initialData: null,
      stream: ubxTcp.pvtMessageStream,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          final style = TextStyle(
              fontWeight: FontWeight.bold,
              color: snapshot.data.fixType < 3 ? Colors.red : Colors.green);
          List<Widget> widgets = List.from([
            Text(
                'LAT\t${snapshot.data.latitude.toStringAsFixed(8).padLeft(15)}',
                style: style),
            Text(
              'LOG\t${snapshot.data.longitude.toStringAsFixed(8).padLeft(15)}',
              style: style,
            ),
            Text(
              'Height\t${snapshot.data.height.toStringAsFixed(3).padLeft(16)}',
              style: style,
            ),
          ]);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgets,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class RecieverFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UbxTcpListener ubxTcp =
        Provider.of<UbxTcpListener>(context, listen: true);
    bool connected = ubxTcp.connected;
    //////print('RecieverFloatingActionButton');
    return FloatingActionButton(
      child: connected ? Icon(Icons.stop) : Icon(Icons.play_arrow),
      onPressed: connected
          ? () async {
              await ubxTcp.stopListen();
              await ubxTcp.disconnect();
            }
          : () async {
              var res = await ubxTcp.connectTcp();
              if (res != null) await ubxTcp.startListen();
            },
    );
  }
}
