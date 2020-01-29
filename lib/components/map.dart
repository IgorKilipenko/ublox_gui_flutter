import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ublox_gui_flutter/model/gnss/gnss_channel.dart';
import 'dart:async';
import 'package:ublox_gui_flutter/ublox/ubx_decoder.dart';

class MapStreamWidget extends StatefulWidget {
  final Stream<PvtMessage> stream;
  final CameraPosition initialCameraPosition;
  final double minDistChanged;
  MapStreamWidget(
      {Key key,
      @required this.stream,
      this.initialCameraPosition =
          const CameraPosition(target: LatLng(54.688841, 82.044015), zoom: 15),
      this.minDistChanged = 0.000001})
      : super();
  @override
  _MapStreamWidgetState createState() => _MapStreamWidgetState();
}

class _MapStreamWidgetState extends State<MapStreamWidget> {
  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController _controller;
  StreamSubscription _streamSubscription;
  Marker _currMarket;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: widget.initialCameraPosition,
      onMapCreated: (GoogleMapController controller) async {
        print('On map created');
        if (!_completer.isCompleted) {
          _completer.complete(controller);
          setState(() {
            _controller = controller;
          });

          print('Map complete');

          final batteryLevel = await GnssChannel().getBatteryLevel();
          print('Battery Level -> $batteryLevel %.');

          final _gpsProviders = await GnssChannel().getGpsProviders();
          _gpsProviders?.forEach((prov) => print('GPS Provider -> $prov'));

          final locationEnabled = await GnssChannel().isLocationEnabled();
          print('IsLocationEnabled = $locationEnabled');
        }
      },
      markers: _currMarket == null ? null : [_currMarket].toSet(),
    );
  }

  @override
  void didUpdateWidget(MapStreamWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _streamSubscription.cancel();
      _listen();
    }
  }

  @override
  void initState() {
    super.initState();
    //currMarket = Marker(
    //    markerId: MarkerId("curr_loc"),
    //    icon: BitmapDescriptor.defaultMarker,
    //    position: LatLng(54.688841, 82.044015),
    //    infoWindow: InfoWindow(title: 'Position'));
    _listen();
  }

  void _listen() {
    _streamSubscription = widget.stream.listen((value) {
      final LatLng pos = LatLng(value.latitude, value.longitude);
      _moveCamera(currPosition: pos, prevPosition: _currMarket?.position);
      setState(() {
        _currMarket = Marker(
            markerId: MarkerId("curr_loc"),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(value.latitude, value.longitude),
            infoWindow: InfoWindow(title: 'Receiver position'));
      });
    }, onError: (e) {
      print('Erreor listening, err -> $e');
    }, onDone: () {
      print('Done listen');
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<bool> _moveCamera(
      {@required LatLng currPosition, LatLng prevPosition}) async {
    bool isChanged = prevPosition == null ||
        (prevPosition.latitude - currPosition.latitude).abs() >
                widget.minDistChanged &&
            (prevPosition.longitude - currPosition.longitude).abs() >
                widget.minDistChanged;

    if (isChanged) {
      await _controller.animateCamera(CameraUpdate.newLatLng(currPosition));
      return true;
    } else {
      return false;
    }
  }

  //Future<void> _getBatteryLevel() async {
  //  String batteryLevel;
  //  try {
  //    final int result = await platform.invokeMethod('getBatteryLevel');
  //    batteryLevel = 'Battery level at $result % .';
  //  } on PlatformException catch (e) {
  //    batteryLevel = "Failed to get battery level: '${e.message}'.";
  //  }
//
  //  setState(() {
  //    _batteryLevel = batteryLevel;
  //  });
  //}

  //Future<void> _getGpsProviders() async {
  //  List<String> gpsProviders;
  //  try {
  //    final List<dynamic> result =
  //        await gnssChannel.invokeMethod('getGpsProviders');
  //    gpsProviders = result.cast<String>();
  //  } on PlatformException catch (e) {
  //    print("Failed to get gnss providers: '${e.message}'.");
  //    gpsProviders = null;
  //  }
//
  //  setState(() {
  //    _gpsProviders = gpsProviders;
  //  });
  //}
//
  //Future<void> _isLocationEnabled() async {
  //  bool enabled;
  //  try {
  //    final bool result = await gnssChannel.invokeMethod('isLocationEnabled');
  //    enabled = result;
  //  } on PlatformException catch (e) {
  //    print("Failed to get isLocationEnabled: '${e.message}'.");
  //    enabled = null;
  //  }
//
  //  setState(() {
  //    _locationEnabled = enabled;
  //  });
  //}
}
