import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ublox_gui_flutter/geodesy/vector3d.dart';
import 'package:ublox_gui_flutter/rtklib/rtklib_impl.dart';
import 'dart:math' as Math;

class RtkrcvImpl {
  final RtklibImpl _rtklib;

  void Function(Pointer<Double>, Pointer<Double>) _pos2ecefFunc;

  RtkrcvImpl() : _rtklib = RtklibImpl() {
    _initFunctionPtrs();
  }

  void _initFunctionPtrs() {
    final pos2ecefPtr = _rtklib.lookupFunctionPointer<
        Void Function(Pointer<Double>, Pointer<Double>)>('pos2ecef');
    _pos2ecefFunc = pos2ecefPtr
        .asFunction<void Function(Pointer<Double>, Pointer<Double>)>();
  }

  Point3d pos2ecef(double latitude, longitude, [double height = 0]) {
    assert(_pos2ecefFunc != null);
    final double ro = 180.0 / Math.pi;

    //final size = 8 * sizeOf<Double>();
    final int len = 3;
    final Pointer<Double> bufferPos = allocate<Double>(count: len);
    bufferPos[0] = latitude / ro;
    bufferPos[1] = longitude / ro;
    bufferPos[2] = height;

    final Pointer<Double> resBuf = allocate<Double>(count: len);

    _pos2ecefFunc(bufferPos, resBuf);

    Point3d res = Point3d(resBuf[0], resBuf[1], resBuf[2]);
    free(bufferPos);
    free(resBuf);

    return res;
  }

/* rtk server functions ------------------------------------------------------*/
  //rtksvrstart   ---< rtksvr.c

}

class Llh_t extends Struct {
  @Double()
  double latitude;

  @Double()
  double longitude;

  @Double()
  double height;

  factory Llh_t.allocate(double latitude, double longitude, double height) =>
      allocate<Llh_t>(count: 3).ref
        ..latitude = latitude
        ..longitude = longitude
        ..height = height;
}

class Pont3d_t extends Struct {
  @Double()
  double x;

  @Double()
  double y;

  @Double()
  double z;

  factory Pont3d_t.allocate(double x, double y, double z) =>
      allocate<Pont3d_t>(count: 3).ref
        ..x = x
        ..y = y
        ..z = z;
}
