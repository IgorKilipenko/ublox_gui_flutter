import 'dart:io';
import 'dart:typed_data';
import './class_ids.dart';
import 'dart:math';

final MAX_MSG_LEN = 8192;
final HEADER_BYTES = const [181, 98];

final UBX_SYNCH_1 = 0xb5;
final UBX_SYNCH_2 = 0x62;

const PAYLOAD_OFFSET = 6;
const CHECKSUM_LEN = 2;

class UbxDecoder {
  num _nbyte = 0;
  Uint8List _uintBuffer = new Uint8List(MAX_MSG_LEN);
  ByteData _dataView;

  UbxDecoder() {
    this._dataView = new ByteData.view(_uintBuffer.buffer);
  }

  //_allowedClasses = [];

  final _payloadOffset = 6;
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

    var pvtMsg = new PvtMessage();
    pvtMsg.classId = ClassIds['NAV'];
    pvtMsg.msgId = NavMessageIds['PVT'];
    pvtMsg.iTow = payload.getUint32(0, Endian.little);
    pvtMsg.year = payload.getUint16(4, Endian.little);
    pvtMsg.month = payload.getUint8(6);
    pvtMsg.day = payload.getUint8(7);
    pvtMsg.hour = payload.getUint8(8);
    pvtMsg.min = payload.getUint8(9);
    pvtMsg.sec = payload.getUint8(10);
    //  ..............
    pvtMsg.fixType = payload.getUint8(20);
    pvtMsg.carrierSolution = payload.getUint8(21) >> 6;
    pvtMsg.numSatInSolution = payload.getUint8(23);
    pvtMsg.longitude = _getDeg(payload.getInt32(24, Endian.little), 7);
    pvtMsg.latitude = _getDeg(payload.getInt32(28, Endian.little), 7);
    pvtMsg.height = _getDistM(payload.getInt32(32, Endian.little));
    pvtMsg.heightMSL = _getDistM(payload.getInt32(36, Endian.little));
    pvtMsg.horizontalAcc = _getDistM(payload.getUint32(40, Endian.little));
    pvtMsg.verticalAcc = _getDistM(payload.getUint32(44, Endian.little));
    pvtMsg.groundSpeed = _getDistM(payload.getInt32(60, Endian.little));
    pvtMsg.headMotion = _getDeg(payload.getInt32(64, Endian.little), 5);
    pvtMsg.speedAcc = _getDistM(payload.getUint32(68, Endian.little));
    pvtMsg.headAcc = _getDeg(payload.getUint32(72, Endian.little), 5);
    pvtMsg.pDOP = payload.getUint16(76, Endian.little);
    pvtMsg.headVeh = _getDeg(payload.getInt32(84, Endian.little), 5);
    // ...............

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
      this._length = new Uint16List.view(this._uintBuffer.buffer, 4, 2)[0]+8;
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
    num offset = 2;
    num len = length - 2;

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

    final payload = new ByteData.view(
        view.buffer, PAYLOAD_OFFSET, packetLength - CHECKSUM_LEN - PAYLOAD_OFFSET);

    final checkSum = view.getInt16(packetLength - CHECKSUM_LEN, Endian.little);
    UbxPacket ubxPacket = new UbxPacket();

    ubxPacket.sync_1 = sync_1;
    ubxPacket.sync_2 = sync_2;
    ubxPacket.classId = classId;
    ubxPacket.msgId = msgId;
    ubxPacket.payloadLength = payloadLength;
    ubxPacket.packetLength = packetLength;
    ubxPacket.payload = payload;
    ubxPacket.checkSum = checkSum;

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
  num fixType;
  num carrierSolution;
  num numSatInSolution;
  num longitude;
  num latitude;
  num height;
  num heightMSL;
  num horizontalAcc;
  num verticalAcc;
  num groundSpeed;
  num headMotion;
  num speedAcc;
  num headAcc;
  num pDOP;
  num headVeh;
  // ...............

}

num _getDeg(num deg, num e) {
  return deg / pow(10, e);
}

num _getDistM(val) {
  return val / 1000;
}

ByteBuffer _cloneByteBuffer(ByteBuffer buffer, int start, int end) {
  assert(buffer != null);
  assert(start >= 0 && end >= start && end <= buffer.lengthInBytes);

  var ub = new Uint8List.view(buffer);
  return ub.sublist(start, end).buffer;
}
