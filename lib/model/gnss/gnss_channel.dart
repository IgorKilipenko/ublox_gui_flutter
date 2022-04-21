import 'package:flutter/services.dart';
import 'dart:async';

import 'package:ublox_gui_flutter/model/gnss/measurment.dart';

class GnssRaw {
  int id;
}

class GnssChannel {
  final MethodChannel _gpsLocationMethodChannel;
  final MethodChannel _batteryChennel;
  final EventChannel _gpsLocationEventChannel;
  final EventChannel _gnssRawEventChannel;
  Stream<List<MeasurmentItem>> _rawDataStream;
  Stream<dynamic> _locationDataStream;
  static GnssChannel _instace;

  StreamController<String> _gnssRawStateController =
      StreamController<String>.broadcast(onListen: () {
    print('Start listen stream RawStateController');
  }, onCancel: () {
    print('Cancel listen stream RawStateController');
  });
  Stream<String> get serviceController => _gnssRawStateController.stream;

  factory GnssChannel() {
    if (_instace != null) return _instace;

    final gpsLocationMethodChannel =
        MethodChannel("ublox_gui_flutter/gps_location/methods");
    final batteryChennel = MethodChannel('samples.flutter.dev/battery');
    final gpsLocationEventChannel =
        EventChannel("ublox_gui_flutter/gps_location/events");
    final gnssRawEventChannel =
        EventChannel("ublox_gui_flutter/gnss_raw_data/events");
    _instace = GnssChannel._private(
        gpsLocationMethodChannel: gpsLocationMethodChannel,
        batteryChennel: batteryChennel,
        gpsLocationEventChannel: gpsLocationEventChannel,
        gnssRawEventChannel: gnssRawEventChannel);
    return _instace;
  }

  GnssChannel._private(
      {MethodChannel gpsLocationMethodChannel,
      MethodChannel batteryChennel,
      EventChannel gpsLocationEventChannel,
      EventChannel gnssRawEventChannel})
      : _gpsLocationMethodChannel = gpsLocationMethodChannel,
        _batteryChennel = batteryChennel,
        _gpsLocationEventChannel = gpsLocationEventChannel,
        _gnssRawEventChannel = gnssRawEventChannel;

  //Stream<GnssRaw> get gnssRawStream => _gnssRawController.stream;

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
          await _gpsLocationMethodChannel.invokeMethod('getGpsProviders');
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
      final bool result =
          await _gpsLocationMethodChannel.invokeMethod('isLocationEnabled');
      enabled = result;
    } on PlatformException catch (e) {
      print("Failed to get isLocationEnabled: '${e.message}'.");
    }
    return enabled;
  }

  Stream<dynamic> getGpsLocationStream() {
    _locationDataStream ??= _gpsLocationEventChannel?.receiveBroadcastStream();
    return _locationDataStream;
  }

  //Stream<dynamic> getGnssRawStream() {
  //  _rawDataStream ??= _gnssRawEventChannel
  //      ?.receiveBroadcastStream()
  //      .transform(StreamTransformer<dynamic, MeasurmentItem>.fromHandlers(
  //        handleData: (dynamic data, EventSink sink) {
  //          //sink.add(data * 2);
  //          try {
  //            if (data is List<dynamic>) {
  //              //print(data);
  //              var mes = MeasurmentItem.fromList(data /*as List<dynamic>*/);
  //              sink.add(mes);
  //            } else {
  //              //sink.add(data);
  //              if (_gnssRawStateController.hasListener) {
  //                _gnssRawStateController.add(data.toString());
  //              }
  //            }
  //          } catch (e) {
  //            print('$e');
  //          }
  //        },
  //        handleError: (error, stacktrace, sink) {
  //          sink.addError('Something went wrong: $error');
  //        },
  //        handleDone: (sink) {
  //          sink.close();
  //        },
  //      ));
  //  return _rawDataStream;
  //}

  static const FKEY_MEAS = "measurements";
  static const FKEY_CODE = "code";
  static const FKEY_CLOCK = "clock";
  static const MEAS_CODE = 0x10;
  static const STAT_CODE = 0x05;
  Stream<List<MeasurmentItem>> getGnssRawStream() {
    _rawDataStream ??= _gnssRawEventChannel.receiveBroadcastStream().transform<List<MeasurmentItem>>(
            StreamTransformer<dynamic, List<MeasurmentItem>>.fromHandlers(
          handleData: (dynamic data, EventSink sink) {
            //sink.add(data * 2);
            try {
              if (data is Map<dynamic, dynamic>) {
                final packet = data.cast<String, dynamic>();
                if (packet[FKEY_CODE] == MEAS_CODE) {
                  final res = _decodeMeasBatch(packet);
                  sink.add(res);
                }
              } else {
                //sink.add(data);
                if (_gnssRawStateController.hasListener) {
                  _gnssRawStateController.add(data.toString());
                }
              }
            } catch (e) {
              print('$e');
            }
          },
          handleError: (error, stacktrace, sink) {
            sink.addError('Something went wrong: $error');
          },
          handleDone: (sink) {
            sink.close();
          },
        ));
    return _rawDataStream;
  }

  static List<MeasurmentItem> _decodeMeasBatch(Map<String, dynamic> packet) {
    assert(packet != null);
    assert(packet.containsKey(FKEY_MEAS));
    assert(packet[FKEY_MEAS] is List<dynamic>);

    final batch = packet[FKEY_MEAS] as List<dynamic>;
    final res = List<MeasurmentItem>();
    for (final List<dynamic> measItem in batch) {
      final mes = MeasurmentItem.fromList(measItem);
      res.add(mes);
    }
    return res;
  }
}
