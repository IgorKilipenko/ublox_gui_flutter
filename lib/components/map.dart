import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ublox_gui_flutter/screens/state/ui_state.dart';
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
  Marker _currMarker;
  bool _receiverEnabled = false;
  UiState _uiState;

  @override
  Widget build(BuildContext context) {
    if (_uiState == null) return Center(child: CircularProgressIndicator());
    //print('${uiState.mapInfo?.lastCameraPossition}');
    return GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _uiState.mapInfo?.lastCameraPossition ??
            widget.initialCameraPosition,
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
        onCameraMove: (camPos) {
          if (_uiState != null) {
            _uiState.setMapInfo(MapInfo(
                lastCameraPossition: camPos,
                receiverEnabled: _receiverEnabled,
                lastMarkerPosition: _currMarker?.position));
          }
        },
        markers: _currMarker != null ? Set<Marker>.from([_currMarker]) : null);
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
    print('Map initState');
    super.initState();
    _uiState = Provider.of<UiState>(context, listen: false);
    _initMarkersFromUiState();
    //currMarket = Marker(
    //    markerId: MarkerId("curr_loc"),
    //    icon: BitmapDescriptor.defaultMarker,
    //    position: LatLng(54.688841, 82.044015),
    //    infoWindow: InfoWindow(title: 'Position'));
    _listen();
  }

  void _listen() {
    _streamSubscription = widget.stream.listen((value) {
      if (!_receiverEnabled) _receiverEnabled = true;
      final LatLng pos = LatLng(value.latitude, value.longitude);
      _moveCamera(currPosition: pos, prevPosition: _currMarker?.position);
      setState(() {
        _currMarker = _buildMarker(value.latitude, value.longitude);
      });
    }, onError: (e) {
      print('Erreor listening, err -> $e');
    }, onDone: () {
      print('Done listen');
      _receiverEnabled = false;
    });
  }

  Marker _buildMarker(double latitude, double longitude) {
    return Marker(
        markerId: MarkerId("curr_loc"),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: 'Receiver position'));
  }

  void _initMarkersFromUiState() {
    if (_uiState.mapInfo != null && _uiState.mapInfo.lastMarkerPosition != null) {
      final double latitude = _uiState.mapInfo.lastMarkerPosition.latitude;
      final double longitude = _uiState.mapInfo.lastMarkerPosition.longitude;
      _currMarker = _buildMarker(latitude, longitude);
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    print('Map disposing');
    super.dispose();
  }

  @override
  void deactivate() {
    print('Map deactivating');
    super.deactivate();
  }

  Future<bool> _moveCamera(
      {@required LatLng currPosition, LatLng prevPosition}) async {
    if (_controller == null) return false;
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
