import 'dart:ffi'; // For FFI
import 'dart:io';
import 'dart:math' as Math;
import 'package:ffi/ffi.dart';
import 'package:ublox_gui_flutter/geodesy/vector3d.dart'; // For Platform.isX
import 'package:meta/meta.dart' show visibleForTesting;

final DynamicLibrary nativeRtklib = Platform.isAndroid
    ? DynamicLibrary.open("librtklib_test.so")
    : DynamicLibrary.process();

final _pos2ecef_func = nativeRtklib
    .lookup<
        NativeFunction<
            Void Function(
                Pointer<Double> pos, Pointer<Double> res)>>("pos2ecef")
    .asFunction<void Function(Pointer<Double>, Pointer<Double>)>();

Point3d pos2ecef(double latitude, longitude, [double height = 0]) {
  assert(_pos2ecef_func != null);
  final double ro = 180.0 / Math.pi;

  //final size = 8 * sizeOf<Double>();
  final int len = 3;
  final Pointer<Double> bufferPos = allocate<Double>(count: len);
  bufferPos[0] = latitude / ro;
  bufferPos[1] = longitude / ro;
  bufferPos[2] = height;

  final Pointer<Double> resBuf = allocate<Double>(count: len);

  _pos2ecef_func(bufferPos, resBuf);

  Point3d res = Point3d(resBuf[0], resBuf[1], resBuf[2]);
  free(bufferPos);
  free(resBuf);

  return res;
}

class RtklibImpl {
  static RtklibImpl _instance;
  DynamicLibrary _dynamicLibrary;
  static const String LIB_NAME = 'librtklib_test.so';

  @visibleForTesting
  RtklibImpl.private(this._dynamicLibrary);

  factory RtklibImpl() {
    if (_instance == null) {
      final dynamicLib = Platform.isAndroid
          ? DynamicLibrary.open(LIB_NAME)
          : DynamicLibrary.process();

      _instance = RtklibImpl.private(dynamicLib);
    }

    return _instance;
  }

  Pointer<NativeFunction<T>> lookupFunctionPointer<T extends Function>(
      String name) {
    assert(_dynamicLibrary != null);

    final  funcPtr =
        _dynamicLibrary.lookup<NativeFunction<T>>(name);
    if (funcPtr == null) {
      final Exception err = Exception('Lookup function $name is null');
      print('Error, ${err.toString()}');
      throw err;
    }

    return funcPtr;
  }
}
