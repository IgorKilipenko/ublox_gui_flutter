import '../ublox/ubx_decoder.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';

UbxDecoder _decoder = new UbxDecoder();

class UbxTcpListener with ChangeNotifier {
  double _latitude;
  double _longitude;
  bool _connected = false;
  static Socket _socket;

  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get connected => _connected;
  Socket get socket => _socket;

  UbxTcpListener() {
    start();
  }

  Future<void> start() async {
    if (!_connected)
      await this._connectTcp(_decodeUbx);
  }

  void setPvt(PvtMessage msg) {
    _latitude = msg.latitude;
    _longitude = msg.longitude;
    notifyListeners();
  }

  Future<bool> _connectTcp(onData) async {
    try {
      _socket = await Socket.connect('192.168.1.52', 7042);
      _connected = _socket != null ? true : false;
      print('connected');
      socket.listen(onData, onDone: () {
        _connected = false;
        _socket = null;
        notifyListeners();
        print('Disconnected');
      }, onError: (e, StackTrace s) {
        _connected = false;
        _socket = null;
        notifyListeners();
        print('Disconnected,\nerror: $e\ntrace: $s');
      }, cancelOnError: true);
    } catch (e) {
      _connected = false;
      _socket = null;
      print('Not connected, $e');
    } finally {
      
    }
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
            print('Log: ${msg.longitude}');
            print('Lat: ${msg.latitude}');

            setPvt(msg);
          }
        }
      } catch (e, s) {
        print('Exception details:\n $e');
        print('Stack trace:\n $s');
      }
    });
  }
}