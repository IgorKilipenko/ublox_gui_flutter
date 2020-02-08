import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:ublox_gui_flutter/model/ublox/ubx_decoder.dart';
import 'package:flutter/foundation.dart';

@immutable
class UbxConnectionStaus {
  final bool connected;
  final String host;
  final int port;
  UbxConnectionStaus(
      {@required this.connected, @required this.host, @required this.port});
}

class UbxTcpListener with ChangeNotifier {
  final UbxDecoder _decoder = new UbxDecoder();
  String _host;
  int _port;
  double _latitude = 0;
  double _longitude = 0;
  bool _connected = false;
  static Socket _socket;
  StreamSubscription<Uint8List> _streamSubscription;
  //StreamController<LatLng> latLngStream = StreamController<LatLng>();

  UbxTcpListener({String host = '192.168.1.52', int port = 7042})
      : _host = host,
        _port = port;

  StreamController<PvtMessage> _pvtMsgController =
      StreamController<PvtMessage>.broadcast(onListen: () {
    print('Start listen stream pvt msgs');
  }, onCancel: () {
    print('Cancel listen stream pvt msgs');
  });
  StreamController<UbxConnectionStaus> _serviceController =
      StreamController<UbxConnectionStaus>.broadcast(onListen: () {
    print('Start listen stream pvt msgs');
  }, onCancel: () {
    print('Cancel listen stream pvt msgs');
  });

  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get connected => _connected;
  Socket get socket => _socket;

  Stream<PvtMessage> get pvtMessageStream => _pvtMsgController.stream;
  Stream<UbxConnectionStaus> get serviceController => _serviceController.stream;

  Future disconnect() async {
    if (_socket != null && _connected) {
      try {
        await stopListen();
        await _socket.flush();
        _connected = false;
        await _socket.close();
        _socket.destroy();
        print('Disconnected');
      } catch (e) {
        print('Stop connection error, $e');
      }
    }
    if (_connected || _socket != null) {
      _connected = false;
      _socket = null;
      notifyListeners();
      if (_pvtMsgController.hasListener) {
        _serviceController.add(UbxConnectionStaus(
            connected: _connected, host: _host, port: _port));
      }
    }
  }

  void _setPvt(PvtMessage msg, {bool withNotifyListeners = true}) {
    //_latitude = msg.latitude;
    //_longitude = msg.longitude;
    //if (withNotifyListeners) notifyListeners();
    if (_pvtMsgController.hasListener) {
      _pvtMsgController.add(msg);
    }
  }

  Future<StreamSubscription<Uint8List>> startListen() async {
    if (socket == null) {
      print('Socket is null');
      return null;
    }
    if (_streamSubscription != null) {
      await _streamSubscription.cancel();
      print('Cancel listen for restart');
    }

    _streamSubscription = socket.listen(_decodeUbx, onDone: () async {
      print('OnDone stoped....');
      await disconnect();
      print('Disconnected | onDone');
    }, onError: (e, StackTrace s) async {
      await disconnect();
      print('Disconnected,\nerror: $e\ntrace: $s');
    }, cancelOnError: true);

    return _streamSubscription;
  }

  Future<dynamic> stopListen() async {
    if (socket == null || _streamSubscription == null) {
      print('Socket is null');
      return false;
    }
    var res;
    try {
      res = await _streamSubscription.cancel();
      print('Cancel Stream Subscription, return $res');
    } catch (e) {
      print('Error cancel Stream Subscription, e -> $e');
    }

    return res;
  }

  Future<bool> connectTcp({bool forceConnect = false}) async {
    if (!forceConnect && _socket != null && _connected) {
      print('Alrady connected');
      return _connected;
    }
    try {
      _socket = await Socket.connect(_host, _port);
      _connected = _socket != null ? true : false;
      print('connected');
      notifyListeners();
      //_streamSubscription = await startListen();
    } on SocketException catch (e) {
      print('Not connected, $e');
    } catch (e) {
      //await disconnect();
      print('Not connected, SocketException -> $e');
    } finally {}
    return _connected;
  }

  void _decodeUbx(List<int> buffer) {
    buffer.forEach((int b) {
      try {
        UbxPacket packet = _decoder.inputData(b);
        if (packet != null) {
          //print(packet.classId);
          if (packet.classId == 0x01 && packet.msgId == 0x07) {
            PvtMessage msg = packet as PvtMessage;
            //print('Log: ${msg.longitude}');
            //print('Lat: ${msg.latitude}');

            _setPvt(msg);
          }
        }
      } catch (e, s) {
        print('Exception details:\n $e');
        print('Stack trace:\n $s');
      }
    });
  }
}
