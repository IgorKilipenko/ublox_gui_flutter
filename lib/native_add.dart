import 'dart:ffi'; // For FFI
import 'dart:io';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ublox_gui_flutter/geodesy/vector3d.dart'; // For Platform.isX

final DynamicLibrary nativeAddLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_add.so")
    : DynamicLibrary.process();

final int Function(int x, int y) nativeAdd = nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();

final DynamicLibrary nativeRtklib = Platform.isAndroid
    ? DynamicLibrary.open("librtklib_test.so")
    : DynamicLibrary.process();

final _pos2ecef_func = nativeRtklib
    .lookup<
        NativeFunction<
            Void Function(
                Pointer<Double> pos, Pointer<Double> res)>>("pos2ecef")
    .asFunction<void Function(Pointer<Double>, Pointer<Double>)>();
//final pos2ecef = _pos2ecef_ptr.asFunction<void Function(Pointer<Double>, double)>();

/// Transform geodetic position to ecef position
Point3d pos2ecef(double latitude, longitude, [double height = 0]) {
  assert(_pos2ecef_func != null);
  final double ro = 180.0 / Math.pi;
  double lat_rad = latitude / ro, lon_rad = longitude / ro;

  //final size = 8 * sizeOf<Double>();
  final int len = 3;
  final Pointer<Double> bufferPos = allocate<Double>(count: len);
  bufferPos[0] = lat_rad;
  bufferPos[1] = lon_rad;
  bufferPos[2] = height;

  final Pointer<Double> resBuf = allocate<Double>(count: len);

  _pos2ecef_func(bufferPos, resBuf);

  Point3d res = Point3d(resBuf[0], resBuf[1], resBuf[2]);
  free(bufferPos);
  free(resBuf);

  return res;
}
