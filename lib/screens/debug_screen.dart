import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ublox_gui_flutter/model/gnss/measurment.dart';
import 'package:ublox_gui_flutter/model/gnss/gnss_channel.dart';
import 'package:ublox_gui_flutter/native_add.dart';
import 'package:ublox_gui_flutter/routes.dart';
import 'dart:async';

import 'package:ublox_gui_flutter/model/rtklib/Gtime.dart';
import 'package:ublox_gui_flutter/screens/screen_arguments.dart';

class DebugScreen extends StatelessWidget {
  static const String routeName = ScreenRoutes.DEBUG;

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          title: Text("Debug"),
        ),
        body: Container(
            child: Center(
          child: Column(
            children: <Widget>[
              FutureBuilder<Map<String, dynamic>>(
                future: _testChannel(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Text(
                            'Battery Level -> ${snapshot.data['batteryLevel']}%'),
                        Text(
                            'GPS Provider -> ${snapshot.data['gpsProviders']?.toString()}%'),
                        Text(
                            'IsLocationEnabled -> ${snapshot.data['locationEnabled'].toString().toUpperCase()}'),
                      ],
                    );
                  }
                  return Text('Debug screen');
                },
              ),
              StreamBuilder<dynamic>(
                initialData: 'not data',
                stream: GnssChannel().getGpsLocationStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('Gnss stream -> ${snapshot.data?.toString()}');
                  }
                },
              ),
              StreamBuilder<dynamic>(
                initialData: 'not data',
                stream: GnssChannel().getGnssRawStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data is List<MeasurmentItem>) {
                      final list = snapshot.data as List<MeasurmentItem>;
                      final widgets = list
                          .map((m) => Container(
                                height: 150,
                                child: Column(children: <Widget>[
                                  Text(
                                      'accumulatedDeltaRangeMeters -> ${m.accumulatedDeltaRangeMeters}'),
                                  Text(
                                      'accumulatedDeltaRangeState -> ${m.accumulatedDeltaRangeState}'),
                                  Text(
                                      'accumulatedDeltaRangeUncertaintyMeters -> ${m.accumulatedDeltaRangeUncertaintyMeters}'),
                                  Text(
                                      'automaticGainControlLevelDb -> ${m.automaticGainControlLevelDb}'),
                                  Text(
                                      'carrierFrequencyHz -> ${m.carrierFrequencyHz}'),
                                  Text('cn0DbHz -> ${m.cn0DbHz}'),
                                  Text('codeType -> ${m.codeType}'),
                                ]),
                              ))
                          .toList();
                      return Flexible(child: ListView(children: widgets, padding: new EdgeInsets.symmetric(vertical: 8.0),));
                    }
                    return Text(
                        'RawGnss stream -> ${snapshot.data?.toString()}');
                  }
                  return null;
                },
              ),
            ],
          ),
        )));
  }

  Future<Map<String, dynamic>> _testChannel() async {
    final batteryLevel = await GnssChannel().getBatteryLevel();
    print('Battery Level -> $batteryLevel %.');

    final gpsProviders = await GnssChannel().getGpsProviders();
    gpsProviders?.forEach((prov) => print('GPS Provider -> $prov'));

    final locationEnabled = await GnssChannel().isLocationEnabled();
    print('IsLocationEnabled = $locationEnabled');

    return <String, dynamic>{
      'batteryLevel': batteryLevel,
      'gpsProviders': gpsProviders,
      'locationEnabled': locationEnabled
    };
  }

  void _testNative() {
    print('Native FFI 2 + 5 = ${nativeAdd(2, 5)}');
    print('pos2ecef -> ${pos2ecef(54.9332925, 82.9307390, 97.0).toString()}');

    try {
      final gtime = Gtime();
      final utcTime = Gtime_t.allocate(
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000, 18);
      /////final gpsTime = gtime.utc2gpst(utcTime);
      /////print('Utc time -> time = ${utcTime.time}, sec = ${utcTime.sec}');
      /////print('Gps time -> time = ${gpsTime.time}, sec = ${gpsTime.sec}');
    } catch (e) {
      print('!!!!!!!!!$e');
    }
  }
}
