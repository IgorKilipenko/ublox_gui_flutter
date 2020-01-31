import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ublox_gui_flutter/geodesy/vector3d.dart';


class UiState with ChangeNotifier {
  GoogleMapController _controller;
  LatLng _currPos;
  bool _drawerOpened = false;
  MapInfo _mapInfo;

  GoogleMapController get mapController => _controller;
  LatLng get lastPosition => _currPos;
  bool get drawerOpened => _drawerOpened;
  MapInfo get mapInfo => _mapInfo;

  void setMapController(GoogleMapController controller) {
    assert(controller != null);
    _controller = controller;
    notifyListeners();
  }

  void setLastPosition(LatLng pos, [bool equalInore = true]) {
    LatLng prevPos = _currPos;
    _currPos = pos;
    bool notify = prevPos == null ||
        !equalInore ||
        !listEquals(<double>[pos.latitude, pos.longitude],
            <double>[prevPos.latitude, prevPos.longitude]);
    if (notify) {
      notifyListeners();
    }
  }

  void setMapInfo(MapInfo info){
    _mapInfo = info;
    notifyListeners();
  }

  void setLastPosition_(LatLng Function(LatLng prevPos) cb) {
    _currPos = cb(_currPos);
    notifyListeners();
  }

  void setDrawerOpened(bool opened) {
    _drawerOpened = opened;
    notifyListeners();
  }

}

@immutable
class MapInfo {
  final CameraPosition lastCameraPossition;
  final LatLng lastMarkerPosition;
  final bool receiverEnabled;

  MapInfo({this.lastCameraPossition, this.receiverEnabled, this.lastMarkerPosition});
}