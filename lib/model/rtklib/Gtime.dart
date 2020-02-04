import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ublox_gui_flutter/model/rtklib/rtklib_impl.dart';

class Gtime_t extends Struct {
  @Int64()
  int time;

  @Double()
  double sec;

  factory Gtime_t.allocate(int time, double sec) {
    try {
      final ptr = allocate<Gtime_t>(count: 1).ref
        ..time = time
        ..sec = sec;
      print('Gtime_t Ptr allocated');
      return ptr;
    } catch (e) {
      print('Error allocate, $e');
      throw e;
    }
  }
}

typedef FFi_utc2gpst_ffi = Pointer<Gtime_t> Function(Pointer<Gtime_t>);

class Gtime {
  final RtklibImpl _rtklib;

  FFi_utc2gpst_ffi _utc2gpstFunc;

  Gtime() : _rtklib = RtklibImpl() {
    _initFunctionPtrs();
  }

  void _initFunctionPtrs() {
    final utc2gpstPtr =
        _rtklib.lookupFunctionPointer<FFi_utc2gpst_ffi>('utc2gpst_ffi');
    _utc2gpstFunc = utc2gpstPtr.asFunction();
  }

  Gtime_t utc2gpst(Gtime_t utc) {
    final gpsTimePtr = _utc2gpstFunc(utc.addressOf);
    return gpsTimePtr.ref;
  }

  //EXPORT gtime_t gpst2time(int week, double sec);
}
