import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ublox_gui_flutter/model/gnss/gnss_channel.dart';
import 'package:ublox_gui_flutter/native_add.dart';
import 'package:ublox_gui_flutter/routes.dart';
import 'dart:async';

import 'package:ublox_gui_flutter/rtklib/Gtime.dart';
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
                    return Text(
                        'RawGnss stream -> ${snapshot.data?.toString()}');
                  }
                },
              ),
              StreamBuilder<dynamic>(
                initialData: 'not data',
                stream: GnssChannel().getGnssRawStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        'RawGnss stream -> ${snapshot.data?.toString()}');
                  }
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
