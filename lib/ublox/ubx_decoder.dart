import 'dart:typed_data';
import 'dart:math';
import 'package:ublox_gui_flutter/ublox/class_ids.dart';

const MAX_MSG_LEN = 8192;
const HEADER_BYTES = const [181, 98];

const UBX_SYNCH_1 = 0xb5;
const UBX_SYNCH_2 = 0x62;

const PAYLOAD_OFFSET = 6;
const CHECKSUM_LEN = 2;

class UbxDecoder {
  num _nbyte = 0;
  Uint8List _uintBuffer = new Uint8List(MAX_MSG_LEN);
  //ByteData _dataView;

  UbxDecoder() {
    //this._dataView = new ByteData.view(_uintBuffer.buffer);
  }

  //_allowedClasses = [];

  //final _payloadOffset = 6;
  var _length = 0;
  bool syncHeader(num data, Uint8List buffer) {
    buffer[0] = buffer[1];
    buffer[1] = data;

    return this.checkHeader(buffer);
  }

  bool checkHeader(Uint8List buffer) {
    return buffer[0] == HEADER_BYTES[0] && buffer[1] == HEADER_BYTES[1];
  }

  dynamic decodePvtMsg(UbxPacket ubxPacket) {
    if (ubxPacket.payloadLength < 92) {
      print('Warn decode PVT message, payload length < 92');
      return null;
    }

    var payload = ubxPacket.payload;

    final PvtMessage pvtMsg = PvtMessage.init(
      classId: ClassIds['NAV'],
      msgId: NavMessageIds['PVT'],
      iTow: payload.getUint32(0, Endian.little),
      year: payload.getUint16(4, Endian.little),
      month: payload.getUint8(6),
      day: payload.getUint8(7),
      hour: payload.getUint8(8),
      min: payload.getUint8(9),
      sec: payload.getUint8(10),
      //  ..............
      fixType: payload.getUint8(20),
      carrierSolution: payload.getUint8(21) >> 6,
      numSatInSolution: payload.getUint8(23),
      longitude: _getDeg(payload.getInt32(24, Endian.little), 7),
      latitude: _getDeg(payload.getInt32(28, Endian.little), 7),
      height: _getDistM(payload.getInt32(32, Endian.little)),
      heightMSL: _getDistM(payload.getInt32(36, Endian.little)),
      horizontalAcc: _getDistM(payload.getUint32(40, Endian.little)),
      verticalAcc: _getDistM(payload.getUint32(44, Endian.little)),
      groundSpeed: _getDistM(payload.getInt32(60, Endian.little)),
      headMotion: _getDeg(payload.getInt32(64, Endian.little), 5),
      speedAcc: _getDistM(payload.getUint32(68, Endian.little)),
      headAcc: _getDeg(payload.getUint32(72, Endian.little), 5),
      pDOP: payload.getUint16(76, Endian.little),
      headVeh: _getDeg(payload.getInt32(84, Endian.little), 5),
      // ...............
    );

    return pvtMsg;
  }

  UbxPacket inputData(num data) {
    if (this._nbyte == 0) {
      this._length = 0;
      if (!this.syncHeader(data, this._uintBuffer)) {
        return null;
      } else {
        this._nbyte = 2;
        return null;
      }
    }

    this._uintBuffer[this._nbyte++] = data;

    if (this._nbyte == PAYLOAD_OFFSET) {
      //****this._length = new Uint16Array(this._buffer, 4, 2)[0] + 8;
      this._length = new Uint16List.view(this._uintBuffer.buffer, 4, 2)[0] + 8;
      if (this._length > MAX_MSG_LEN) {
        this._nbyte = 0;
        return null;
      }
    }

    if (this._nbyte == this._length) {
      this._nbyte = 0;
      if (!this.checkHeader(this._uintBuffer)) {
        return null;
      }
      if (this.testChecksum(this._uintBuffer, this._length)) {
        ////********const ubxPacket = this.decodePacket(new DataView(buffer.buffer.slice(0, this._length)));
        UbxPacket ubxPacket = this.decodePacket(new ByteData.view(
            _cloneByteBuffer(this._uintBuffer.buffer, 0, this._length)));
        if (ubxPacket != null) {
          //////this.emit(UbxDecoder._emits.ubxPacket, ubxPacket);
          if (ubxPacket.classId == ClassIds['NAV']) {
            if (ubxPacket.msgId == NavMessageIds['PVT']) {
              var pvtMsg = this.decodePvtMsg(ubxPacket);
              if (pvtMsg != null) {
                /////this.emit(
                /////    UbxDecoder._emits.pvtMsg,
                /////    pvtMsg
                /////);
                return pvtMsg;
              }
            }

            //////case NavMessageIds.HPPOSLLH:
            //////  const hpposllhMsg = this.decodeNavHPPOSLLHMsg(ubxPacket);
            //////  if (hpposllhMsg) {
            //////    this.emit(UbxDecoder._emits.hpposllh, hpposllhMsg);
            //////    return hpposllhMsg;
            //////  }

          } else {
            ///// this.emit(UbxDecoder._emits.message, ubxPacket);
          }
        }

        return ubxPacket;
      }
    }

    return null;
  }

  bool testChecksum(Uint8List buffer, num length) {
    Uint8List ck = new Uint8List.fromList([0, 0]);
    final int offset = 2;
    final int len = length - 2;

    //num i = offset;
    for (int i = offset; i < len; i++) {
      ck[0] += buffer[i];
      ck[1] += ck[0];
    }
    bool res = (ck[0] == buffer[length - 2]) && (ck[1] == buffer[length - 1]);
    return res;
  }

  UbxPacket decodePacket(ByteData view) {
    final sync_1 = view.getUint8(0);
    final sync_2 = view.getUint8(1);
    final classId = view.getUint8(2);
    final msgId = view.getUint8(3);
    final payloadLength = view.getUint16(4, Endian.little);
    final packetLength = PAYLOAD_OFFSET + payloadLength + CHECKSUM_LEN;
    if (packetLength <= 0 || view.lengthInBytes < packetLength) {
      print('Error decode ubxPacket. Buffer length !== packetLength');
      return null;
    }

    ///const payload = new DataView(
    ///    view.buffer.slice(PAYLOAD_OFFSET, packetLength - CHECKSUM_LEN)
    ///);

    final payload = new ByteData.view(view.buffer, PAYLOAD_OFFSET,
        packetLength - CHECKSUM_LEN - PAYLOAD_OFFSET);

    final checkSum = view.getInt16(packetLength - CHECKSUM_LEN, Endian.little);
    final UbxPacket ubxPacket = UbxPacket.init(
        sync_1: sync_1,
        sync_2: sync_2,
        classId: classId,
        msgId: msgId,
        payloadLength: payloadLength,
        packetLength: packetLength,
        payload: payload,
        checkSum: checkSum);

    //ubxPacket.sync_1 = sync_1;
    //ubxPacket.sync_2 = sync_2;
    //ubxPacket.classId = classId;
    //ubxPacket.msgId = msgId;
    //ubxPacket.payloadLength = payloadLength;
    //ubxPacket.packetLength = packetLength;
    //ubxPacket.payload = payload;
    //ubxPacket.checkSum = checkSum;

    return ubxPacket;
  }
}

class UbxPacket {
  int sync_1;
  int sync_2;
  int classId;
  int msgId;
  int payloadLength;
  int packetLength;
  ByteData payload;
  int checkSum;

  UbxPacket();

  UbxPacket.init(
      {this.sync_1,
      this.sync_2,
      this.classId,
      this.msgId,
      this.payloadLength,
      this.packetLength,
      this.payload,
      this.checkSum});
}

class PvtMessage extends UbxPacket {
  num iTow;
  num year;
  num month;
  num day;
  num hour;
  num min;
  num sec;
  //  ..............
  int fixType;
  int carrierSolution;
  int numSatInSolution;
  double longitude;
  double latitude;
  double height;
  double heightMSL;
  num horizontalAcc;
  num verticalAcc;
  num groundSpeed;
  num headMotion;
  num speedAcc;
  num headAcc;
  num pDOP;
  num headVeh;
  // ...............

  PvtMessage();

  PvtMessage.init({
    sync_1,
    sync_2,
    classId,
    msgId,
    payloadLength,
    packetLength,
    payload,
    checkSum,
    iTow,
    year,
    month,
    day,
    hour,
    min,
    sec,
    //  ..............
    this.fixType,
    this.carrierSolution,
    this.numSatInSolution,
    this.longitude,
    this.latitude,
    this.height,
    this.heightMSL,
    this.horizontalAcc,
    this.verticalAcc,
    this.groundSpeed,
    this.headMotion,
    this.speedAcc,
    this.headAcc,
    this.pDOP,
    this.headVeh,
    // ...............
  }) : super.init(
            sync_1: sync_1,
            sync_2: sync_2,
            classId: classId,
            msgId: msgId,
            payloadLength: payloadLength,
            packetLength: packetLength,
            payload: payload,
            checkSum: checkSum);
}

double _getDeg(num deg, num e) {
  return deg / pow(10, e);
}

num _getDistM(num val) {
  return val / 1000;
}

ByteBuffer _cloneByteBuffer(ByteBuffer buffer, int start, int end) {
  assert(buffer != null);
  assert(start >= 0 && end >= start && end <= buffer.lengthInBytes);

  var ub = new Uint8List.view(buffer);
  return ub.sublist(start, end).buffer;
}
