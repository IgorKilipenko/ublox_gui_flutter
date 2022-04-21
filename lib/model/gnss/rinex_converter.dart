import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:ublox_gui_flutter/model/gnss/Measurment.dart';
import 'package:ublox_gui_flutter/model/gnss/constellation.dart';

class RawConverter {
  // Flags to check wether the measurement is correct or not
  // https://developer.android.com/reference/android/location/GnssMeasurement.html#getState()
  static const STATE_2ND_CODE_LOCK = 0x00010000;
  static const STATE_BDS_D2_BIT_SYNC = 0x00000100;
  static const STATE_BDS_D2_SUBFRAME_SYNC = 0x00000200;
  static const STATE_BIT_SYNC = 0x00000002;
  static const STATE_CODE_LOCK = 0x00000001;
  static const STATE_GAL_E1BC_CODE_LOCK = 0x00000400;
  static const STATE_GAL_E1B_PAGE_SYNC = 0x00001000;
  static const STATE_GAL_E1C_2ND_CODE_LOCK = 0x00000800;
  static const STATE_GLO_STRING_SYNC = 0x00000040;
  static const STATE_GLO_TOD_DECODED = 0x00000080;
  static const STATE_GLO_TOD_KNOWN = 0x00008000;
  static const STATE_MSEC_AMBIGUOUS = 0x00000010;
  static const STATE_SBAS_SYNC = 0x00002000;
  static const STATE_SUBFRAME_SYNC = 0x00000004;
  static const STATE_SYMBOL_SYNC = 0x00000020;
  static const STATE_TOW_DECODED = 0x00000008;
  static const STATE_TOW_KNOWN = 0x00004000;
  static const STATE_UNKNOWN = 0x00000000;

  static const ADR_STATE_UNKNOWN = 0x00000000;
  static const ADR_STATE_VALID = 0x00000001;
  static const ADR_STATE_RESET = 0x00000002;
  static const ADR_STATE_HALF_CYCLE_RESOLVED = 0x00000008;
  static const ADR_STATE_HALF_CYCLE_REPORTED = 0x00000010;
  static const ADR_STATE_CYCLE_SLIP = 0x00000004;

  static const double SPEED_OF_LIGHT = 299792458.0; // [m/s]
  static const int GPS_WEEKSECS = 604800; // Number of seconds in a week
  static const double NS_TO_S = 1.0e-9;
  static const double NS_TO_M = NS_TO_S *
      SPEED_OF_LIGHT; // Constant to transform from nanoseconds to meters
  static const int BDST_TO_GPST =
      14; // Leap seconds difference between BDST and GPST
  static const int GLOT_TO_UTC =
      10800; // Time difference between GLOT and UTC in seconds
  // Origin of the GPS time scale
  static final DateTime GPSTIME = DateTime(1980, 1, 6);
  static const int DAYSEC = 86400; // Number of seconds in a day
  static const int CURRENT_GPS_LEAP_SECOND = 18;
  static const List<String> OBS_LIST = ['C', 'L', 'D', 'S'];

  static const String EPOCH_STR = 'epoch';

  static const double GLO_L1_CENTER_FREQ = 1.60200e9;
  static const double GLO_L1_DFREQ = 0.56250e6;
}

class Observation {
  final String constellation;
  final List<String> _obscodes = List<String>();
  List<String> get obscodes => _obscodes;
  Observation(this.constellation, {Iterable<String> obscodes}) {
    if (obscodes != null) _obscodes.addAll(obscodes);
  }
  void setObscode(String code) {}
}

class RawObservation {
  final int accumulatedDeltaRangeState;
  final int constellationType;
  final int nultipathIndicator;
  final int state;
  final int svid;

  const RawObservation(
      {@required this.accumulatedDeltaRangeState,
      @required this.constellationType,
      @required this.nultipathIndicator,
      @required this.state,
      @required this.svid});

  double get_frequency(MeasurmentItem measurement) {
    final v = measurement.carrierFrequencyHz;
    return v ?? 154 * 10.23e6;
    //return 154 * 10.23e6 if v == '' else v
  }

  /// Obtain the measurement code (RINEX 3 format)
  /// >>> get_obscode({'CarrierFrequencyHz': 1575420030.0, 'ConstellationType': 1})
  /// '1C'
  /// >>> get_obscode({'CarrierFrequencyHz': 1176450050.0, 'ConstellationType': 5})
  /// '5X'
  String get_obscode(MeasurmentItem measurement) {
    final band = get_rnx_band_from_freq(get_frequency(measurement));

    final attr = get_rnx_attr(band,
        constellation: get_constellation(measurement),
        state: measurement.state);

    return '$band$attr';
  }

  /// Obtain the frequency band
  /// >>> get_rnx_band_from_freq(1575420030.0)
  /// 1
  /// >>> get_rnx_band_from_freq(1600875010.0)
  /// 1
  /// >>> get_rnx_band_from_freq(1176450050.0)
  /// 5
  /// >>> get_rnx_band_from_freq(1561097980.0)
  /// 2
  int get_rnx_band_from_freq(double frequency) {
    // Backwards compatibility with empty fields (assume GPS L1)
    final int ifreq = frequency == null
        ? 154
        : (frequency / 10.23e6)
            .round(); //154 if frequency == '' else round(frequency / 10.23e6)

    // QZSS L1 (154), GPS L1 (154), GAL E1 (154), and GLO L1 (156)
    if (ifreq >= 154)
      return 1;
    // QZSS L5 (115), GPS L5 (115), GAL E5 (115)
    else if (ifreq == 115)
      return 5;
    // BDS B1I (153)
    else if (ifreq == 153)
      return 2;
    else {
      throw Exception(
          "Cannot get Rinex frequency band from frequency [ $frequency ]. Got the following integer frequency multiplier [ $ifreq ]");
    }

    //return ifreq;
  }

  /// Generate the RINEX 3 attribute from a given band. Assumes 'C' for L1/E1
  /// frequency and 'Q' for L5/E5a frequency. For E5a it assumes Q tracking.
  String get_rnx_attr(int band,
      {String constellation = 'G', int state = 0x00}) {
    String attr = 'C';

    // Make distinction between GAL E1C and E1B code
    if (band == 1 && constellation == 'E') if ((state &
                RawConverter.STATE_GAL_E1C_2ND_CODE_LOCK) ==
            0 &&
        (state & RawConverter.STATE_GAL_E1B_PAGE_SYNC) != 0) attr = 'B';

    // GAL E5, QZSS L5, and GPS L5 (Q)
    if (band == 5) attr = 'Q';

    // BDS B1I
    if (band == 2 && constellation == 'C') attr = 'I';

    return attr;
  }

  /// Return the constellation letter from a given measurement
  /// >>> get_constellation({'ConstellationType': 1})
  /// 'G'
  /// >>> get_constellation({'ConstellationType': 6})
  /// 'E'
  /// >>> get_constellation({'ConstellationType': 3})
  /// 'R'
  /// >>> get_constellation({'ConstellationType': 5})
  /// 'C'
  String get_constellation(MeasurmentItem measurement) {
    final int ctype = measurement.constellationType;

    return Constellation.getLetter(ctype);
  }

  /// Obtain the observable list (array of RINEX 3.0 observable codes), particularized
  /// per each constellation, e.g.
  /// obs = {
  ///     'G' : [C1C, L1C, D1C, S1C, C5Q],
  ///     'E' : [C1C, L1C, D1C, C5Q],
  ///     'R' : [C1P, C2P]
  /// }
  List<Observation> get_obslist_from_batch(Iterable<MeasurmentItem> batch) {
    final obslist = List<Observation>(batch.length);
    for (final measurement in batch) {
      final obscode = get_obscode(measurement);

      final constellation = get_constellation(measurement);

      Observation item = obslist.firstWhere(
          (obs) => obs.constellation == constellation,
          orElse: () => null);
      if (item == null) {
        item = Observation(constellation);
        obslist.add(item);
      }

      item.obscodes.add(obscode);
    }

    return obslist;
  }

  
}
