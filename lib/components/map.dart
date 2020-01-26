import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ublox_gui_flutter/model/ubx_tcp_listener.dart';
import 'package:ublox_gui_flutter/screens/state/ui_state.dart';
import 'dart:async';

import 'package:ublox_gui_flutter/ublox/ubx_decoder.dart';

class MapWidget extends StatelessWidget {
  final Completer<GoogleMapController> _completer = Completer();
  //GoogleMapController _controller;
  //LatLng _currPos;
  final double _minDistChanged = 5.0;

  @override
  Widget build(BuildContext context) {
    print('Build Map');
    UiState uiState = Provider.of<UiState>(context, listen: false);
    UbxTcpListener listener =
        Provider.of<UbxTcpListener>(context, listen: true);
    bool connected = listener.connected;
    if (connected && uiState.mapController != null) {
      final newPos = LatLng(listener.latitude, listener.longitude);
      _moveCamera(
          currPosition: newPos,
          minDistChanged: _minDistChanged,
          prevPosition: uiState.lastPosition,
          uiState: uiState);
    }

    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition:
          CameraPosition(target: LatLng(54.688841, 82.044015), zoom: 15),
      onMapCreated: (GoogleMapController controller) async {
        print('On map created');
        if (!_completer.isCompleted) {
          _completer.complete(controller);
          uiState.setMapController(controller);
          print('Map complete');
        }
      },
      markers: [
        Marker(
            markerId: MarkerId("curr_loc"),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(listener.latitude, listener.longitude),
            infoWindow: InfoWindow(title: 'Position'))
      ].toSet(),
    );
  }

  Future<bool> _moveCamera(
      {@required LatLng currPosition,
      @required UiState uiState,
      @required double minDistChanged,
      LatLng prevPosition}) async {
    assert(uiState.mapController != null);
    bool isChanged = prevPosition == null ||
        (prevPosition.latitude - currPosition.latitude).abs() >
                _minDistChanged &&
            (prevPosition.longitude - currPosition.longitude).abs() >
                _minDistChanged;

    if (isChanged) {
      await uiState.mapController
          .animateCamera(CameraUpdate.newLatLng(currPosition));
      uiState.setLastPosition(currPosition);
      return true;
    } else {
      return false;
    }
  }
}

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
}
