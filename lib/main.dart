import './ublox/ubx_decoder.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';
import './model/ubx_tcp_listener.dart';

Socket socket;
UbxDecoder _decoder = new UbxDecoder();

////void _decodeUbx(List<int> buffer) {
////  buffer.forEach((int b) {
////    try {
////      UbxPacket packet = _decoder.inputData(b);
////      if (packet != null) {
////        //print(packet.classId);
////        if (packet.classId == 0x01 && packet.msgId == 0x07) {
////          PvtMessage msg = packet as PvtMessage;
////          print('Log: ${msg.longitude}');
////          print('Lat: ${msg.latitude}');
////        }
////      }
////    } catch (e, s) {
////      print('Exception details:\n $e');
////      print('Stack trace:\n $s');
////    }
////  });
////}

Future<Socket> _connectTcp(onData) async {
  try {
    socket = await Socket.connect('192.168.1.52', 7042);
    print('connected');
    socket.listen(onData);
    return socket;
  } catch (e) {
    print('Not connected, $e');
  }
}

void main() {
  runApp(UbxGuiApp());
}

class UbxGuiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        //                                     <--- MultiProvider
        providers: [
          ChangeNotifierProvider<UbxTcpListener>(
              create: (context) => UbxTcpListener()),
          //ChangeNotifierProvider<AnotherModel>(
          //    create: (context) => AnotherModel()),
        ],
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.orange),
          home: Scaffold(
              appBar: AppBar(title: Text('Ubx GUI FLUTTER')),
              body: Card(
                child: Column(
                  children: <Widget>[_buildReceiverPane(), Divider()],
                ),
              )),
        ));
  }

  Widget _buildReceiverPane() {
    return ListTile(
        leading: RecieverFloatingActionButton(),
        title: Text('Receiver'),
        subtitle: Container(
          child: PositionWidget(),
        ),
        trailing: Icon(Icons.more_vert));
  }
}

class RecieverFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UbxTcpListener listener = Provider.of<UbxTcpListener>(context);
    return FloatingActionButton(
      child: listener.connected ? Icon(Icons.stop) : Icon(Icons.play_arrow),
      onPressed: listener.connected
          ? () async => await listener.stop()
          : () async => await listener.start(),
    );
  }
}

class PositionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UbxTcpListener listener = Provider.of<UbxTcpListener>(context);
    bool connected = listener.connected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('LAT\t${(connected ? listener.latitude.toStringAsFixed(8) : '').padLeft(15)}', style: connected ? TextStyle(fontWeight: FontWeight.bold ) : null,),
        Text('LOG\t${(connected ? listener.longitude.toStringAsFixed(8) : '').padLeft(15)}', style: connected ? TextStyle(fontWeight: FontWeight.bold ) : null,),
      ],
    );
  }
}
