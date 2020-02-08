import 'package:flutter/services.dart';
import 'dart:async';

class GnssRaw {
  int id;
}

class GnssChannel {
  final MethodChannel _gpsLocationMethodChannel;
  final MethodChannel _batteryChennel;
  final EventChannel _gpsLocationEventChannel;
  final EventChannel _gnssRawEventChannel;
  Stream<dynamic> _rawDataStream;
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

  Stream<dynamic> getGnssRawStream() {
    _rawDataStream ??= _gnssRawEventChannel
        ?.receiveBroadcastStream()
        .transform(StreamTransformer<dynamic, MeasurmentItem>.fromHandlers(
          handleData: (dynamic data, EventSink sink) {
            //sink.add(data * 2);
            try {
              if (data is List<dynamic>) {
                //print(data);
                var mes = MeasurmentItem.fromList(data as List<dynamic>);
                sink.add(mes);
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
}

class MeasurmentItem {
  MeasurmentItem(
      {this.describeContents,
      this.accumulatedDeltaRangeMeters,
      this.accumulatedDeltaRangeState,
      this.accumulatedDeltaRangeUncertaintyMeters,
      this.automaticGainControlLevelDb,
      this.carrierFrequencyHz,
      this.cn0DbHz,
      this.codeType,
      this.constellationType,
      this.multipathIndicator,
      this.pseudorangeRateMetersPerSecond,
      this.pseudorangeRateUncertaintyMetersPerSecond,
      this.receivedSvTimeNanos,
      this.snrInDb,
      this.state,
      this.svid,
      this.timeOffsetNanos});
  final num describeContents;
  final num accumulatedDeltaRangeMeters;
  final num accumulatedDeltaRangeState;
  final num accumulatedDeltaRangeUncertaintyMeters;
  final num automaticGainControlLevelDb;
  final num carrierFrequencyHz;
  final num cn0DbHz;
  final String codeType;
  final num constellationType;
  final num multipathIndicator;
  final num pseudorangeRateMetersPerSecond;
  final num pseudorangeRateUncertaintyMetersPerSecond;
  final num receivedSvTimeNanos;
  final num snrInDb;
  final num state;
  final num svid;
  final num timeOffsetNanos;

  factory MeasurmentItem.fromList(List<dynamic> list) {
    assert(list != null);
    if (list == null) return null;
    return MeasurmentItem(
        describeContents: list[RawMeasMapper.describeContents] as num,
        accumulatedDeltaRangeMeters:
            list[RawMeasMapper.accumulatedDeltaRangeMeters] as num,
        accumulatedDeltaRangeState:
            list[RawMeasMapper.accumulatedDeltaRangeState] as num,
        accumulatedDeltaRangeUncertaintyMeters:
            list[RawMeasMapper.accumulatedDeltaRangeUncertaintyMeters] as num,
        automaticGainControlLevelDb:
            list[RawMeasMapper.automaticGainControlLevelDb] as num,
        carrierFrequencyHz: list[RawMeasMapper.carrierFrequencyHz] as num,
        cn0DbHz: list[RawMeasMapper.cn0DbHz] as num,
        codeType: list[RawMeasMapper.codeType] as String,
        constellationType: list[RawMeasMapper.constellationType] as num,
        multipathIndicator: list[RawMeasMapper.multipathIndicator] as num,
        pseudorangeRateMetersPerSecond:
            list[RawMeasMapper.pseudorangeRateMetersPerSecond] as num,
        pseudorangeRateUncertaintyMetersPerSecond:
            list[RawMeasMapper.pseudorangeRateUncertaintyMetersPerSecond]
                as num,
        receivedSvTimeNanos: list[RawMeasMapper.receivedSvTimeNanos] as num,
        snrInDb: list[RawMeasMapper.snrInDb] as num,
        state: list[RawMeasMapper.state] as num,
        svid: list[RawMeasMapper.svid] as num,
        timeOffsetNanos: list[RawMeasMapper.timeOffsetNanos] as num);
  }
}

class RawMeasMapper {
  static final int describeContents = 0;
  static final int accumulatedDeltaRangeMeters = 1;
  static final int accumulatedDeltaRangeState = 2;
  static final int accumulatedDeltaRangeUncertaintyMeters = 3;
  static final int automaticGainControlLevelDb = 4;
  static final int carrierFrequencyHz = 5;
  static final int cn0DbHz = 6;
  static final int codeType = 7;
  static final int constellationType = 8;
  static final int multipathIndicator = 9;
  static final int pseudorangeRateMetersPerSecond = 10;
  static final int pseudorangeRateUncertaintyMetersPerSecond = 11;
  static final int receivedSvTimeNanos = 12;
  static final int snrInDb = 13;
  static final int state = 14;
  static final int svid = 15;
  static final int timeOffsetNanos = 16;
}
