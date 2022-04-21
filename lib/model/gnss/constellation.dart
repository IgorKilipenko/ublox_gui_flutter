class Constellation {
  static const _UNKNOWN =
      const MapEntry<int, String>(ConstellationType.UNKNOWN, 'X');
  static const _GPS = const MapEntry<int, String>(ConstellationType.GPS, 'G');
  static const _SBAS = MapEntry<int, String>(ConstellationType.SBAS, 'S');
  static const _GLONASS = MapEntry<int, String>(ConstellationType.GLONASS, 'R');
  static const _QZSS = const MapEntry<int, String>(ConstellationType.QZSS, 'J');
  static const _BEIDOU =
      const MapEntry<int, String>(ConstellationType.BEIDOU, 'C');
  static const _GALILEO =
      const MapEntry<int, String>(ConstellationType.GALILEO, 'E');
  static const _IRNSS =
      const MapEntry<int, String>(ConstellationType.IRNSS, 'I');

  static final _letters = Map<int, String>.fromEntries(
      [_UNKNOWN, _GPS, _SBAS, _GLONASS, _QZSS, _BEIDOU, _GALILEO, _IRNSS]);
  static String getLetter(int code) {
    return _letters.containsKey(code) ? _letters[code] : null;
  }

  operator [](int code) {
    return getLetter(code);
  }
}

class ConstellationType {
  static const int UNKNOWN = 0x00000000;
  static const int GPS = 0x00000001;
  static const int SBAS = 0x00000002;
  static const int GLONASS = 0x00000003;
  static const int QZSS = 0x00000004;
  static const int BEIDOU = 0x00000005;
  static const int GALILEO = 0x00000006;
  static const int IRNSS = 0x00000007;
}
