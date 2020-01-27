import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';
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
          print('Battery Lrvrl -> $_batteryLevel');
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
    _getBatteryLevel();
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

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }
}
