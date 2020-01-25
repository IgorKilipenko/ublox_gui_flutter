import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ublox_gui_flutter/model/ubx_tcp_listener.dart';
import 'package:ublox_gui_flutter/screens/state/ui_state.dart';
import 'dart:async';

class MapWidget extends StatelessWidget {
  final Completer<GoogleMapController> _completer = Completer();
  //GoogleMapController _controller;
  //LatLng _currPos;
  final double _minDistChanged = 5.0;

  @override
  Widget build(BuildContext context) {
    UiState uiState = Provider.of<UiState>(context);
    UbxTcpListener listener = Provider.of<UbxTcpListener>(context);
    bool connected = listener.connected;
    if (connected && uiState.mapController != null) {
      final newPos = LatLng(listener.latitude, listener.longitude);
      _moveCamera(
          currPosition: newPos,
          minDistChanged: _minDistChanged,
          prevPosition: uiState.lastPosition,
          uiState: uiState);
    }

    final GoogleMap _gmapWidget = GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition:
          CameraPosition(target: LatLng(54.688841, 82.044015), zoom: 15),
      onMapCreated: (GoogleMapController controller) async {
        if (!_completer.isCompleted) {
          _completer.complete(controller);
          uiState.setMapController(controller);
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

    return _gmapWidget;
  }

  Future<bool> _moveCamera(
      {@required LatLng currPosition,
      @required UiState uiState,
      @required double minDistChanged,
      LatLng prevPosition}) async {
    print('move!!!!!');
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
