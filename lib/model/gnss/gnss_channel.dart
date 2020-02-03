import 'package:flutter/services.dart';
import 'dart:async';

class GnssRaw {
  int id;
}

class GnssChannel {
  final MethodChannel _gnssChannel;
  final MethodChannel _batteryChennel;
  final EventChannel _gnssEventChannel;
  final EventChannel _gnssRawEventChannel;
  static GnssChannel _instace;

  final StreamController<GnssRaw> _gnssRawController =
      StreamController<GnssRaw>.broadcast(onListen: () {
    print('Start listen gnss raw data');
  }, onCancel: () {
    print('Cancel listen gnss raw data');
  });

  factory GnssChannel() {
    if (_instace != null) return _instace;

    final gnssChannel = MethodChannel('samples.flutter.dev/gnss_measurement');
    final batteryChennel = MethodChannel('samples.flutter.dev/battery');
    final gnssEventChannel = EventChannel("ublox_gui_flutter/gnss_measurement_stream");
    final gnssRawEventChannel = EventChannel("ublox_gui_flutter/gnss_raw_data_stream");
    _instace = GnssChannel._private(
        gnssChannel: gnssChannel, batteryChennel: batteryChennel, gnssEventChannel: gnssEventChannel, gnssRawEventChannel : gnssRawEventChannel);
    return _instace;
  }

  GnssChannel._private(
      {MethodChannel gnssChannel, MethodChannel batteryChennel, EventChannel gnssEventChannel, EventChannel gnssRawEventChannel })
      : this._gnssChannel = gnssChannel,
        this._batteryChennel = batteryChennel,
        _gnssEventChannel = gnssEventChannel,
        _gnssRawEventChannel = gnssRawEventChannel;

  Stream<GnssRaw> get gnssRawStream => _gnssRawController.stream;

  Future<int> getBatteryLevel() async {
    int batteryLevel;
    try {
      batteryLevel = await _batteryChennel.invokeMethod('getBatteryLevel');
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

  Stream<dynamic> getGnssStream() {
    return _gnssEventChannel?.receiveBroadcastStream();
  }

  Stream<dynamic> getGnssRawStream() {
    return _gnssRawEventChannel?.receiveBroadcastStream();
  }
}
