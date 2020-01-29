import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:ublox_gui_flutter/ublox/ubx_decoder.dart';

class GnssRaw {
  int id;
}

class GnssChannel {
  static const _gnssChannel =
      const MethodChannel('samples.flutter.dev/gnss_measurement');

  static const batteryChennel = const MethodChannel('samples.flutter.dev/battery');

  final StreamController<GnssRaw> _gnssRawController = StreamController<GnssRaw>.broadcast(onListen: () {
    print('Start listen gnss raw data');
  }, onCancel: () {
    print('Cancel listen gnss raw data');
  });

  Stream<GnssRaw> get gnssRawStream => _gnssRawController.stream;

  Future<int> getBatteryLevel() async {
    int batteryLevel;
    try {
      batteryLevel = await batteryChennel.invokeMethod('getBatteryLevel');
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
    }
    return batteryLevel;
  }

  Future<List<String>> getGpsProviders() async {
    List<String> gpsProviders;
    try {
      final List<dynamic> result =
          await _gnssChannel.invokeMethod('getGpsProviders');
      gpsProviders = result.cast<String>();
    } on PlatformException catch (e) {
      print("Failed to get gnss providers: '${e.message}'.");
      gpsProviders = null;
    }
    return gpsProviders;
  }

  Future<bool> isLocationEnabled() async {
    bool enabled;
    try {
      final bool result = await _gnssChannel.invokeMethod('isLocationEnabled');
      enabled = result;
    } on PlatformException catch (e) {
      print("Failed to get isLocationEnabled: '${e.message}'.");
    }
    return enabled;
  }
}
