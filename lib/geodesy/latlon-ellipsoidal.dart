import 'package:flutter/foundation.dart';
import 'package:ublox_gui_flutter/geodesy/vector3d.dart';
import './dms.dart';
import 'dart:math' as Math;

@immutable
class Ellipsoid {
  final double _a, _b, _f;
  final String _name;
  const Ellipsoid(
      {@required double a,
      @required double b,
      @required double f,
      @required String name})
      : _a = a,
        _b = b,
        _f = f,
        _name = name;
  //const Ellipsoid.wgs84()
  //    : this(
  //          a: 6378137.0,
  //          b: 6356752.314245,
  //          f: 1 / 298.257223563,
  //          name: 'WGS84');

  String get name => _name;
  double get a => _a;
  double get b => _b;
  double get f => _f;

  static const WGS84 = const Ellipsoid(
      a: 6378137.0, b: 6356752.314245, f: 1 / 298.257223563, name: 'WGS84');
  static const Airy1830 = const Ellipsoid(
      a: 6377563.396, b: 6356256.909, f: 1 / 299.3249646, name: 'Airy1830');
  static const AiryModified = Ellipsoid(
    a: 6377340.189,
    b: 6356034.448,
    f: 1 / 299.3249646,
    name: 'AiryModified',
  );
  static const Bessel1841 = const Ellipsoid(
      a: 6377397.155,
      b: 6356078.962818,
      f: 1 / 299.1528128,
      name: 'Bessel1841');
  static const Clarke1866 = const Ellipsoid(
    a: 6378206.4,
    b: 6356583.8,
    f: 1 / 294.978698214,
    name: 'Clarke1866',
  );
  static const Clarke1880IGN = const Ellipsoid(
      a: 6378249.2, b: 6356515.0, f: 1 / 293.466021294, name: 'Clarke1880IGN');
  static const GRS80 = const Ellipsoid(
    a: 6378137,
    b: 6356752.314140,
    f: 1 / 298.257222101,
    name: 'GRS80',
  );
  static const Intl1924 = const Ellipsoid(
    a: 6378388,
    b: 6356911.946,
    f: 1 / 297.0,
    name: 'Intl1924',
  );
  static const WGS72 = const Ellipsoid(
    a: 6378135,
    b: 6356750.5,
    f: 1 / 298.26,
    name: 'WGS72',
  );

  static final Map<String, Ellipsoid> ellipsoids = const {
    'WGS84': WGS84,
    'Airy1830': Airy1830,
    'AiryModified': AiryModified,
    'Bessel1841': Bessel1841,
    'Clarke1866': Clarke1866,
    'Clarke1880IGN': Clarke1880IGN,
    'GRS80': GRS80,
    'Intl1924': Intl1924,
    'WGS72': WGS72,
  };

  bool equals(Ellipsoid ellipsoid) {
    if (this == ellipsoid) return true;

    final bool eq =
        ellipsoid._a == _a && ellipsoid._b == _b && ellipsoid._f == _f;
    return eq;
  }
}

class Datum {
  final Ellipsoid _ellipsoid;
  final String _name;
  final List<double> _transform;
  const Datum(
      {@required String name,
      @required Ellipsoid ellipsoid,
      List<double> transform = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]})
      : _ellipsoid = ellipsoid,
        _name = name,
        _transform = transform;
  //const Datum.wgs84() : this(name: 'WGS84', ellipsoid: Ellipsoid.WGS84);

  Ellipsoid get ellipsoid => _ellipsoid;
  String get name => _name;
  List<double> get transform => _transform;
  static const WGS84 = const Datum(name: 'WGS84', ellipsoid: Ellipsoid.WGS84);
  static const ED50 = const Datum(
      name: 'ED50',
      ellipsoid: Ellipsoid.Intl1924,
      transform: [89.5, 93.8, 123.1, -1.2, 0.0, 0.0, 0.156]);
  static const ETRS89 = const Datum(
      name: 'ETRS89',
      ellipsoid: Ellipsoid.GRS80,
      transform: [0, 0, 0, 0, 0, 0, 0]);
  static const Irl1975 = const Datum(
      name: 'Irl1975',
      ellipsoid: Ellipsoid.AiryModified,
      transform: [-482.530, 130.596, -564.557, -8.150, 1.042, 0.214, 0.631]);
  static const NAD27 = const Datum(
      name: 'NAD27',
      ellipsoid: Ellipsoid.Clarke1866,
      transform: [8, -160, -176, 0, 0, 0, 0]);
  static const NAD83 = const Datum(
      name: 'NAD83',
      ellipsoid: Ellipsoid.GRS80,
      transform: [
        0.9956,
        -1.9103,
        -0.5215,
        -0.00062,
        0.025915,
        0.009426,
        0.011599
      ]);
  static const NTF = const Datum(
      name: 'NTF',
      ellipsoid: Ellipsoid.Clarke1880IGN,
      transform: [168, 60, -320, 0, 0, 0, 0]);
  static const OSGB36 = const Datum(
      name: 'OSGB36',
      ellipsoid: Ellipsoid.Airy1830,
      transform: [
        -446.448,
        125.157,
        -542.060,
        20.4894,
        -0.1502,
        -0.2470,
        -0.8421
      ]);
  static const Potsdam = const Datum(
      name: 'Potsdam',
      ellipsoid: Ellipsoid.Bessel1841,
      transform: [-582, -105, -414, -8.3, 1.04, 0.35, -3.08]);
  static const TokyoJapan = const Datum(
      name: 'TokyoJapan',
      ellipsoid: Ellipsoid.Bessel1841,
      transform: [148, -507, -685, 0, 0, 0, 0]);
  static const WGS72 = const Datum(
      name: 'WGS72',
      ellipsoid: Ellipsoid.WGS72,
      transform: [0, 0, -4.5, -0.22, 0, 0, 0.554]);

  static const datums = const {
    'ED50': ED50,
    'ETRS89': ETRS89,
    'Irl1975': Irl1975,
    'NAD27': NAD27,
    'NAD83': NAD83,
    'NTF': NTF,
    'OSGB36': OSGB36,
    'Potsdam': Potsdam,
    'TokyoJapan': TokyoJapan,
    'WGS72': WGS72
  };

  //@override
  //bool operator ==(Object other) => (other is Datum) && other._ellipsoid == _ellipsoid && List. other._transform == _transform;

  bool equals(Datum datum) {
    if (datum == this) return true;

    final bool eq = datum._ellipsoid.equals(this._ellipsoid) &&
        (datum._transform == this.transform ||
            listEquals(datum._transform, this._transform));
    return eq;
  }
}

//final datums = {'WGS84': const Datum(Ellipsoid.wgs84())};

@immutable
class LatLonEllipsoidal {
  final double _lat, _lon, _height;
  final Datum _datum;

  LatLonEllipsoidal(
      {@required double lat,
      @required double lon,
      @required double height,
      Datum datum = Datum.WGS84})
      : _lat = Dms.wrap90(lat),
        _lon = Dms.wrap180(lon),
        _height = height,
        _datum = datum;

  LatLonEllipsoidal.parse(
      {@required String lat, @required String lon, @required double height})
      : this(lat: Dms.parse(lat), lon: Dms.parse(lon), height: height);

  double get latitude => _lat;
  double get longitude => _lon;
  double get height => _height;
  Datum get datum => _datum;

  Cartesian toCartesian() {
    final ellipsoid = _datum?._ellipsoid ?? Ellipsoid.WGS84;

    final lat = toRadians(_lat);
    final lon = toRadians(_lon);
    final h = this.height;
    final double a = ellipsoid.a, f = ellipsoid.f;

    final sinLat = Math.sin(lat), cosLat = Math.cos(lat);
    final sinLon = Math.sin(lon), cosLon = Math.cos(lon);

    final eSq = 2 * f - f * f;
    final vi = a / Math.sqrt(1 - eSq * sinLat * sinLat);

    final x = (vi + h) * cosLat * cosLon;
    final y = (vi + h) * cosLat * sinLon;
    final z = (vi * (1 - eSq) + h) * sinLat;

    return Cartesian(x, y, z, datum: _datum);
  }

  bool equals(LatLonEllipsoidal point) {
    if (point == this) return true;
    if ((_lat - point.latitude).abs() > precisionErrorTolerance) return false;
    if ((_lon - point.longitude).abs() > precisionErrorTolerance) return false;
    if ((_height - point.height).abs() > precisionErrorTolerance) return false;
    if (!_datum.equals(point.datum)) return false;
    //if (_referenceFrame != point.referenceFrame) return false;
    //if (_epoch != point.epoch) return false;

    return true;
  }

  LatLonEllipsoidal convertDatum(Datum toDatum) {
    assert(toDatum != null);

    final Cartesian oldCartesian =
        this.toCartesian(); // convert geodetic to cartesian
    final newCartesian = oldCartesian.convertDatum(toDatum); // convert datum
    final newLatLon =
        newCartesian.toLatLon(); // convert cartesian back to geodetic

    return newLatLon;
  }
}

class Cartesian {
  final double _x, _y, _z;
  final Datum _datum;
  Cartesian(double north, double east, double height,
      {Datum datum = Datum.WGS84})
      : _datum = datum,
        _x = north,
        _y = east,
        _z = height;

  Point3d get point => Point3d(_x, _y, _z);

  LatLonEllipsoidal toLatLon() {
    assert(_datum != null && _datum.ellipsoid != null);
    double a = _datum.ellipsoid.a,
        b = _datum.ellipsoid.b,
        f = _datum.ellipsoid.f;
    final double e2 = 2 * f - f * f;
    final double ep2 = e2 / (1 - e2);
    final double p = Math.sqrt(Math.pow(_x, 2) + Math.pow(_y, 2));
    final double R = Math.sqrt(Math.pow(p, 2) + Math.pow(_z, 2));

    final double tanB = (b * _z) / (a * p) * (1 + ep2 * b / R);
    final double sinB = tanB / Math.sqrt(1 + Math.pow(tanB, 2));
    final double cosB = sinB / tanB;

    final double lat = Math.atan2(
        _z + ep2 * b * Math.pow(sinB, 3), p - e2 * a * Math.pow(cosB, 3));

    final double lon = Math.atan2(_y, _x);

    final double sinFi = Math.sin(lat), cosFi = Math.cos(lat);
    final vi = a / Math.sqrt(1 - e2 * Math.pow(sinFi, 2));
    final h = p * cosFi + _z * sinFi - (a * a / vi);

    final point = LatLonEllipsoidal(
        lat: toDegrees(lat), lon: toDegrees(lon), height: h, datum: _datum);

    return point;
  }

  

  Cartesian convertDatum([Datum toDatum = Datum.WGS84]) {
    Cartesian oldCartesian;
    List<double> transform;

    if (_datum == null || _datum.equals(Datum.WGS84)) {
      // converting from WGS 84
      oldCartesian = this;
      transform = toDatum.transform;
    }
    if (toDatum.equals(Datum.WGS84)) {
      // converting to WGS 84; use inverse transform
      oldCartesian = this;
      transform = _datum.transform.map((p) => -p);
    }
    if (transform == null) {
      // neither this.datum nor toDatum are WGS84: convert this to WGS84 first
      oldCartesian = this.convertDatum(Datum.WGS84);
      transform = toDatum.transform;
    }

    Point3d newPoint =
        transformAt(point: oldCartesian.point, transform: transform);

    final Cartesian newCartesian =
        Cartesian(newPoint.x, newPoint.y, newPoint.z, datum: toDatum);

    return newCartesian;
  }

  static Point3d transformAt(
      {@required Point3d point, @required List<double> transform}) {
    assert(transform != null && transform.length == 7);
    final double x1 = point.x, y1 = point.y, z1 = point.z;
    // transform parameters
    final tx = transform[0]; // x-shift in metres
    final ty = transform[1]; // y-shift in metres
    final tz = transform[2]; // z-shift in metres
    final s =
        transform[3] / 1e6 + 1; // scale: normalise parts-per-million to (s+1)
    final rx = toRadians(
        transform[4] / 3600); // x-rotation: normalise arcseconds to radians
    final ry = toRadians(
        transform[5] / 3600); // y-rotation: normalise arcseconds to radians
    final rz = toRadians(
        transform[6] / 3600); // z-rotation: normalise arcseconds to radians

    // apply transform
    final x2 = tx + x1 * s - y1 * rz + z1 * ry;
    final y2 = ty + x1 * rz + y1 * s - z1 * rx;
    final z2 = tz - x1 * ry + y1 * rx + z1 * s;

    return Point3d(x2, y2, z2);
  }
}
