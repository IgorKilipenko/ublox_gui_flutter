import 'dart:math' as Math;

double toFixed(double val, int dp) {
  return double.parse(val.toStringAsFixed(dp));
}

String _dmsSeparator = '\u202f'; // U+202F = 'narrow no-break space'

class Dms {
  static get separator => _dmsSeparator;
  static set separator(char) {
    _dmsSeparator = char;
  }

  static num parse(String dms) {
    // strip off any sign or compass dir'n & split out separate d/m/s
    final List<String> dmsParts = dms
        .trim()
        .replaceAll(RegExp('^-'), '')
        .replaceAll(RegExp('[NSEW]\$', caseSensitive: true), '')
        .split(RegExp('[^0-9.,]+'));
    if (dmsParts.length == 0 || dmsParts[0] == '') return null;

    if (dmsParts[dmsParts.length - 1] == '')
      dmsParts.removeWhere((item) => item == ''); // from trailing symbol

    num deg;
    switch (dmsParts.length) {
      case 3: // interpret 3-part result as d/m/s
        deg = num.parse(dmsParts[0]) / 1 +
            num.parse(dmsParts[1]) / 60 +
            num.parse(dmsParts[2]) / 3600;
        break;
      case 2: // interpret 2-part result as d/m
        deg = num.parse(dmsParts[0]) / 1 + num.parse(dmsParts[1]) / 60;
        break;
      case 1: // just d (possibly decimal) or non-separated dddmmss
        deg = num.parse(dmsParts[0]);
        // check for fixed-width unseparated format eg 0033709W
        //if (/[NS]/i.test(dmsParts)) deg = '0' + deg;  // - normalise N/S to 3-digit degrees
        //if (/[0-9]{7}/.test(deg)) deg = deg.slice(0,3)/1 + deg.slice(3,5)/60 + deg.slice(5)/3600;
        break;
      default:
        return null;
    }
    if (RegExp('^-|[WS]\$', caseSensitive: true).hasMatch(dms.trim()))
      deg = -deg; // take '-', west and south as -ve

    return deg;
  }

  /**
     * Converts decimal degrees to deg/min/sec format
     *  - degree, prime, double-prime symbols are added, but sign is discarded, though no compass
     *    direction is added.
     *  - degrees are zero-padded to 3 digits; for degrees latitude, use .slice(1) to remove leading
     *    zero.
     *
     * @private
     * @param   {number} deg - Degrees to be formatted as specified.
     * @param   {string} [format=d] - Return value as 'd', 'dm', 'dms' for deg, deg+min, deg+min+sec.
     * @param   {number} [dp=4|2|0] - Number of decimal places to use – default 4 for d, 2 for dm, 0 for dms.
     * @returns {string} Degrees formatted as deg/min/secs according to specified format.
     */
//    static String toDms(num deg, [String format='d', int dp]) {
//      assert(deg != null);
//        if (deg == null) return null;  // give up here if we can't make a number from deg
//
//        if (dp == null) {
//            switch (format) {
//                case 'd':   case 'deg':         dp = 4; break;
//                case 'dm':  case 'deg+min':     dp = 2; break;
//                case 'dms': case 'deg+min+sec': dp = 0; break;
//                default:          format = 'd'; dp = 4; break;
//            }
//        }
//
//        deg = deg.abs();  // (unsigned result ready for appending compass dir'n)
//
//        String dms;
//        num d, m, s;
//        String degStr, minStr, secStr;
//        switch (format) {
//
//            case 'd': case 'deg':
//                d = _toFixed(deg, dp);
//                degStr = d.toString().padLeft(4 + dp,'0') +  '°';
//                break;
//            case 'dm': case 'deg+min':
//                d = deg.floor();                       // get component deg
//                m = _toFixed(((deg*60) % 60), dp);           // get component min & round/right-pad
//                if (m == 60) { m = 0; d++; } // check for rounding up
//                degStr = d.toString().padLeft(3, '0');                   // left-pad with leading zeros
//                if (m<10) m = '0' + m;                     // left-pad with leading zeros (note may include decimals)
//                dms = d + '°'+Dms.separator + m + '′';
//                break;
//            case 'dms': case 'deg+min+sec':
//                d = Math.floor(deg);                       // get component deg
//                m = Math.floor((deg*3600)/60) % 60;        // get component min
//                s = (deg*3600 % 60).toFixed(dp);           // get component sec & round/right-pad
//                if (s == 60) { s = (0).toFixed(dp); m++; } // check for rounding up
//                if (m == 60) { m = 0; d++; }               // check for rounding up
//                d = ('000'+d).slice(-3);                   // left-pad with leading zeros
//                m = ('00'+m).slice(-2);                    // left-pad with leading zeros
//                if (s<10) s = '0' + s;                     // left-pad with leading zeros (note may include decimals)
//                dms = d + '°'+Dms.separator + m + '′'+Dms.separator + s + '″';
//                break;
//              default: // invalid format spec!
//        }
//
//        return dms;
//    }

  /// Constrain degrees to range -180..+180 (e.g. for longitude); -181 => 179, 181 => -179.
  ///
  /// @private
  /// @param {number} degrees
  /// @returns degrees within range -180..+180.
  static double wrap180(double degrees) {
    if (-180 < degrees && degrees <= 180)
      return degrees; // avoid rounding due to arithmetic ops if within range
    return (degrees + 540) % 360 - 180; // sawtooth wave p:180, a:±180
  }

  /// Constrain degrees to range -90..+90 (e.g. for latitude); -91 => -89, 91 => 89.
  ///
  /// @private
  /// @param {number} degrees
  /// @returns degrees within range -90..+90.
  static double wrap90(double degrees) {
    if (-90 <= degrees && degrees <= 90)
      return degrees; // avoid rounding due to arithmetic ops if within range
    return ((degrees % 360 + 270) % 360 - 180).abs() -
        90; // triangle wave p:360 a:±90 : fix e.g. -315°
  }

  /// Constrain degrees to range 0..360 (e.g. for bearings); -1 => 359, 361 => 1.
  ///
  /// @private
  /// @param {number} degrees
  /// @returns degrees within range 0..360.
  static double wrap360(double degrees) {
    if (0 <= degrees && degrees < 360)
      return degrees; // avoid rounding due to arithmetic ops if within range
    return (degrees % 360 + 360) % 360; // sawtooth wave p:360, a:360
  }
}

double toRadians(num val) {
  return val * Math.pi / 180;
}

double toDegrees(num val) {
  return val * 180 / Math.pi;
}
