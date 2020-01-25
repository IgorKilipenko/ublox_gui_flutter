import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' as vector;

class Vector3d extends vector.Vector3 {
  Vector3d(double x, double y, double z)
      : super.fromFloat32List(Float32List.fromList([x, y, z]));
  Vector3d plus(Vector3d vec) {
    return this + vec;
  }
}

class Point3d {
  final double _x, _y, _z;
  const Point3d(double x, double y, [double z = 0])
      : _x = x,
        _y = y,
        _z = z;
  factory Point3d.fromList(List<double> list) {
    assert(list.length > 2);
    return Point3d(list[0], list[1], list[2]);
  }

  double get x => _x;
  double get y => _y;
  double get z => _z;
}
