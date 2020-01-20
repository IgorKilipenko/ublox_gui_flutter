import 'package:flutter/foundation.dart';

class ReceiverModel extends ChangeNotifier {
  double _latitude;
  double _longitude;

  ReceiverModel(Map<String, dynamic> previous) :
    _latitude = previous != null ? previous['_latitude'] : null,
    _longitude = previous != null ? previous['_longitude'] : null;

  double get latitude => _latitude;
  double get longitude => _longitude;

  void setPos({double latitude, double longitude}) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }
}