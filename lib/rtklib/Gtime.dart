import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ublox_gui_flutter/rtklib/rtklib_impl.dart';

class Gtime_t extends Struct {
  @Int64()
  int time;

  @Double()
  double sec;

  factory Gtime_t.allocate(int time, double sec) =>
      allocate<Gtime_t>(count: 2).ref
        ..time = time
        ..sec = sec;
}

typedef Ftype = Pointer<Gtime_t> Function(Pointer<Gtime_t>) ;

class Gtime {
    final RtklibImpl _rtklib;

  //Gtime_t Function(int, double) _gpst2timeFunc;

  Gtime() : _rtklib = RtklibImpl() {
    _initFunctionPtrs();
  }

  void _initFunctionPtrs() {
    print(DartRepresentationOf("Gtime_t").toString());
    final gpst2timePtr = _rtklib.lookupFunctionPointer<Pointer<Gtime_t> Function(Pointer<Gtime_t>)>('utc2gpst_ffi');
    final func = gpst2timePtr.asFunction<Ftype>();
    print(func);
    Gtime_t utc = Gtime_t.allocate(DateTime.now().second, 2);
    var p = func(utc.addressOf);
    print('POINTER -> time = ${p.ref.time} sec = ${p.ref.sec}');
    Gtime_t gt = p.ref;
  }

  //EXPORT gtime_t gpst2time(int week, double sec);
}