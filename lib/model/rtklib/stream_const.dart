class StraemType {
  /// stream type: none
  static const int STR_NONE = 0;

  /// stream type: serial
  static const int STR_SERIAL = 1;

  /// stream type: file
  static const int STR_FILE = 2;

  /// stream type: TCP server
  static const int STR_TCPSVR = 3;

  /// stream type: TCP client
  static const int STR_TCPCLI = 4;

  /// stream type: NTRIP server
  static const int STR_NTRIPSVR = 6;

  /// stream type: NTRIP client
  static const int STR_NTRIPCLI = 7;

  /// stream type: ftp
  static const int STR_FTP = 8;

  /// stream type: http
  static const int STR_HTTP = 9;

  /// stream type: NTRIP caster server
  static const int STR_NTRIPC_S = 10;

  /// stream type: NTRIP caster client
  static const int STR_NTRIPC_C = 11;

  /// stream type: UDP server
  static const int STR_UDPSVR = 12;

  /// stream type: UDP server
  static const int STR_UDPCLI = 13;

  /// stream type: memory buffer
  static const int STR_MEMBUF = 14;
}

class StreamMode {
  /// stream mode: read
  static const int STR_MODE_R = 0x1;

  /// stream mode: write
  static const int STR_MODE_W = 0x2;

  /// stream mode: read/write
  static const int STR_MODE_RW = 0x3;
}

class StreamFormat {
  /// stream format: RTCM 2
  static const STRFMT_RTCM2 = 0;

  ///stream format: RTCM 3
  static const STRFMT_RTCM3 = 1;

  ///stream format: NovAtel OEMV/4
  static const STRFMT_OEM4 = 2;

  ///stream format: NovAtel OEM3
  static const STRFMT_OEM3 = 3;

  ///stream format: u-blox LEA-*T
  static const STRFMT_UBX = 4;

  ///stream format: NovAtel Superstar II
  static const STRFMT_SS2 = 5;

  ///stream format: Hemisphere
  static const STRFMT_CRES = 6;

  ///stream format: SkyTraq S1315F
  static const STRFMT_STQ = 7;

  ///stream format: Furuno GW10
  static const STRFMT_GW10 = 8;

  ///stream format: JAVAD GRIL/GREIS
  static const STRFMT_JAVAD = 9;

  ///stream format: NVS NVC08C
  static const STRFMT_NVS = 10;

  ///stream format: BINEX
  static const STRFMT_BINEX = 11;

  ///stream format: Trimble RT17
  static const STRFMT_RT17 = 12;

  ///stream format: Septentrio
  static const STRFMT_SEPT = 13;

  ///stream format: CMR/CMR+
  static const STRFMT_CMR = 14;

  ///stream format: TERSUS
  static const STRFMT_TERSUS = 15;

  ///stream format: Furuno LPY-10000
  static const STRFMT_LEXR = 16;

  ///stream format: RINEX
  static const STRFMT_RINEX = 17;

  ///stream format: SP3
  static const STRFMT_SP3 = 18;

  ///stream format: RINEX CLK
  static const STRFMT_RNXCLK = 19;

  ///stream format: SBAS messages
  static const STRFMT_SBAS = 20;

  ///stream format: NMEA 0183
  static const STRFMT_NMEA = 21;
  static const MAXRCVFMT = 16;
}
