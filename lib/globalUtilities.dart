



// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import 'Components/crc16.dart';
import 'classes/singleton.dart';
import 'dataTypes.dart';
import 'dart:collection';

Logger globalLogger = Logger(printer: PrettyPrinter(methodCount: 0), filter: MyFilter());

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

Uint8List simpleVESCRequest(int messageIndex, {int? optionalCANID}) {
  bool sendCAN = optionalCANID != null;
  var byteData = ByteData(sendCAN ? 8:6); //<start><payloadLen><packetID><crc1><crc2><end>
  byteData.setUint8(0, 0x02);
  byteData.setUint8(1, sendCAN ? 0x03 : 0x01); // Data length
  if (sendCAN) {
    byteData.setUint8(2, 34);
  }
  byteData.setUint8(sendCAN ? 4:2, messageIndex);
  int checksum = CRC16.crc16(byteData.buffer.asUint8List(), 2, sendCAN ? 3:1);
  byteData.setUint16(sendCAN ? 5:3, checksum);
  byteData.setUint8(sendCAN ? 7:5, 0x03); //End of packet


  return byteData.buffer.asUint8List();
}


Future<bool> sendBLEData(BluetoothCharacteristic? txCharacteristic, Uint8List data, bool withoutResponse) async {
  int errorLimiter = 30;
  int packetLength = data.length;
  int bytesSent = 0;
  while (bytesSent < packetLength) {
    int endByte = bytesSent + 20;
    if (endByte > packetLength) {
      endByte = packetLength;
    }
    try {
      await txCharacteristic?.write(
          data.buffer.asUint8List().sublist(bytesSent, endByte),
          withoutResponse: true);
    } on PlatformException catch (err) {
      //TODO: Assuming err.code will always be "write_characteristic_error"
      if (--errorLimiter == 0) {
        globalLogger.e("sendBLEData: Write to characteristic exhausted all attempts. Data not sent. ${txCharacteristic.toString()}"
            "Error: $err");
        return Future.value(false);
      } else {
        //TODO: Observed "write_characteristic_error, no instance of BluetoothGatt, have you connected first?" (believed to be resolved)
        //globalLogger.wtf(err);
        continue; // Try again without incrementing bytesSent
      }
    } catch (e) {
      globalLogger.w("sendBLEData: Exception ${e.toString()}");

      if (--errorLimiter == 0) {
        globalLogger.e("sendBLEData: Write to characteristic exhausted all attempts. Data not sent. ${txCharacteristic.toString()}");
        return Future.value(false);
      } else {
        continue; // Try again without incrementing bytesSent
      }
    }
    bytesSent += 20;
    await Future.delayed(const Duration(milliseconds: 30), () {});
  }
  return Future.value(true);
}
Future<void> requestFirmwareVersion(BluetoothCharacteristic txCharacteristic) async {
  // Uint8List dataToSend = simpleVESCRequest(COMM_PACKET_ID.COMM_FW_VERSION.index);
  //
  // bool success = await sendBLEData(txCharacteristic, dataToSend, false);

  Uint8List packet = simpleVESCRequest(COMM_PACKET_ID.COMM_GET_VALUES_SETUP.index);

// Request COMM_GET_VALUES_SETUP from the ESC
  if (!await sendBLEData(txCharacteristic, packet, true)) {
    globalLogger.e("_requestTelemetry() failed");
  }

  // if (success) {
  //   print("Data was sent successfully");
  // } else {
  //   print("Failed to send data");
  // }
}

class ESCTelemetry {
  ESCTelemetry() {
    v_in = 0;
    temp_mos = 0;
    temp_mos_1 = 0;
    temp_mos_2 = 0;
    temp_mos_3 = 0;
    temp_motor = 0;
    current_motor = 0;
    current_in = 0;
    foc_id = 0;
    foc_iq = 0;
    rpm = 0;
    duty_now = 0;
    amp_hours = 0;
    amp_hours_charged = 0;
    watt_hours = 0;
    watt_hours_charged = 0;
    tachometer = 0;
    tachometer_abs = 0;
    position = 0;
    vesc_id = 0;
    vd = 0;
    vq = 0;
    fault_code = mc_fault_code.FAULT_CODE_NONE;

    //NOTE: Extras for COMM_GET_VALUES_SETUP
    speed = 0;
    battery_level = 0;
    num_vescs = 0;
    battery_wh = 0;
  }
  //FW 5
  double v_in = 0;
  double temp_mos = 0;
  double temp_mos_1 = 0;
  double temp_mos_2 = 0;
  double temp_mos_3 = 0;
  double temp_motor = 0;
  double current_motor = 0;
  double current_in = 0;
  double foc_id = 0;
  double foc_iq = 0;
  double rpm = 0;
  double duty_now  = 0;
  double amp_hours = 0;
  double amp_hours_charged  = 0;
  double watt_hours = 0;
  double watt_hours_charged = 0;
  int tachometer = 0;
  int tachometer_abs = 0;
  double position = 0;
  mc_fault_code fault_code = mc_fault_code.FAULT_CODE_ABS_OVER_CURRENT;
  int vesc_id = 0;
  double vd = 0;
  double vq = 0;

  //NOTE: Extras for COMM_GET_VALUES_SETUP
  double speed = 0;
  double battery_level  = 0;
  int num_vescs = 0;
  double battery_wh = 0;
}

ESCTelemetry processSetupValues(Uint8List payload) {
  int index = 1;
  ESCTelemetry telemetryPacket = ESCTelemetry();

  telemetryPacket.temp_mos = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.temp_motor = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.current_motor = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.current_in = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.duty_now = buffer_get_float16(payload, index, 1000.0); index += 2;
  telemetryPacket.rpm = buffer_get_float32(payload, index, 1.0); index += 4;
  telemetryPacket.speed = buffer_get_float32(payload, index, 1000.0); index += 4;
  telemetryPacket.v_in = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.battery_level = buffer_get_float16(payload, index, 1000.0); index += 2;
  telemetryPacket.amp_hours = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.amp_hours_charged = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.watt_hours = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.watt_hours_charged = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.tachometer = buffer_get_float32(payload, index, 1000.0).toInt(); index += 4;
  telemetryPacket.tachometer_abs = buffer_get_float32(payload, index, 1000.0).toInt(); index += 4;
  telemetryPacket.position = buffer_get_float32(payload, index, 1e6); index += 4;
  telemetryPacket.fault_code = mc_fault_code.values[payload[index++]];
  telemetryPacket.vesc_id = payload[index++];
  telemetryPacket.num_vescs = payload[index++];
  telemetryPacket.battery_wh = buffer_get_float32(payload, index, 1000.0); index += 4;


  return telemetryPacket;
}

ESCTelemetry processTelemetry(Uint8List payload) {
  int index = 1;
  ESCTelemetry telemetryPacket = ESCTelemetry();

  telemetryPacket.temp_mos = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.temp_motor = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.current_motor = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.current_in = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.foc_id = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.foc_iq = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.duty_now = buffer_get_float16(payload, index, 1000.0); index += 2;
  telemetryPacket.rpm = buffer_get_float32(payload, index, 1.0); index += 4;
  telemetryPacket.v_in = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.amp_hours = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.amp_hours_charged = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.watt_hours = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.watt_hours_charged = buffer_get_float32(payload, index, 10000.0); index += 4;
  telemetryPacket.tachometer = buffer_get_int32(payload, index); index += 4;
  telemetryPacket.tachometer_abs = buffer_get_int32(payload, index); index += 4;
  telemetryPacket.fault_code = mc_fault_code.values[payload[index++]];
  telemetryPacket.position = buffer_get_float32(payload, index, 1000000.0); index += 4;
  telemetryPacket.vesc_id = payload[index++];
  telemetryPacket.temp_mos_1 = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.temp_mos_2 = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.temp_mos_3 = buffer_get_float16(payload, index, 10.0); index += 2;
  telemetryPacket.vd = buffer_get_float32(payload, index, 100.0); index += 4;
  telemetryPacket.vq = buffer_get_float32(payload, index, 100.0);

  // if (kDebugMode) {
  //   print("temp_mos: ${telemetryPacket.temp_mos}\n"
  //     "temp_motor ${telemetryPacket.temp_motor}\n"
  //     "current_motor: ${telemetryPacket.current_motor}\n"
  //     "current_in: ${telemetryPacket.current_in}\n"
  //     "foc_id: ${telemetryPacket.foc_id}\n"
  //     "foc_iq: ${telemetryPacket.foc_iq}\n"
  //     "duty_now: ${telemetryPacket.duty_now}\n"
  //     "rpm: ${telemetryPacket.rpm}\n"
  //     // "speed: ${telemetryPacket.speed}"
  //     "v_in: ${telemetryPacket.v_in}\n"
  //     // "battery_level: ${telemetryPacket.battery_level}"
  //     "amp_hours: ${telemetryPacket.amp_hours}\n"
  //     "amp_hours_charged: ${telemetryPacket.amp_hours_charged}\n"
  //     "watt_hours: ${telemetryPacket.watt_hours}\n"
  //     "watt_hours_charged: ${telemetryPacket.watt_hours_charged}\n"
  //     "tachometer: ${telemetryPacket.tachometer}\n"
  //     "tachometer_abs: ${telemetryPacket.tachometer_abs}\n"
  //     "position: ${telemetryPacket.position}\n"
  //     "fault_code: ${telemetryPacket.fault_code}\n"
  //     "vesc_id: ${telemetryPacket.vesc_id}\n"
  //     "num_vescs: ${telemetryPacket.num_vescs}\n"
  //     "battery_wh: ${telemetryPacket.battery_wh}\n"
  //     "vd: ${telemetryPacket.vd}\n"
  //     "vq: ${telemetryPacket.vq}\n"
  //     "temp_mos1: ${telemetryPacket.temp_mos_1}\n"
  //     "temp_mos2: ${telemetryPacket.temp_mos_2}\n"
  //     "temp_mos3: ${telemetryPacket.temp_mos_3}\n"
  // );
  // }
  return telemetryPacket;
}
int buffer_get_int16(Uint8List buffer, int index) {
  var byteData = ByteData.view(buffer.buffer);
  return byteData.getInt16(index);
}

int buffer_get_uint16(Uint8List buffer, int index) {
  var byteData = ByteData.view(buffer.buffer);
  return byteData.getUint16(index);
}

int buffer_get_int32(Uint8List buffer, int index) {
  var byteData = ByteData.view(buffer.buffer);
  return byteData.getInt32(index);
}

int buffer_get_uint32(Uint8List buffer, int index) {
  var byteData = ByteData.view(buffer.buffer);
  return byteData.getUint32(index);
}

int buffer_get_uint64(Uint8List buffer, int index, [Endian endian = Endian.big]) {
  var byteData = ByteData.view(buffer.buffer);
  return byteData.getUint64(index, endian);
}

double buffer_get_float16(Uint8List buffer, int index, double scale) {
  return buffer_get_int16(buffer, index) / scale;
}

double buffer_get_float32(Uint8List buffer, int index, double scale) {
  return buffer_get_int32(buffer, index) / scale;
}

double buffer_get_float32_auto(Uint8List buffer, int index) {
  Uint32List res = Uint32List(1);
  res[0] = buffer_get_uint32(buffer, index);

  int e = (res[0] >> 23) & 0xFF;
  Uint32List sigI = Uint32List(1);
  sigI[0] = res[0] & 0x7FFFFF;
  int negI = res[0] & (1 << 31);
  bool neg = negI > 0 ? true : false;

  double sig = 0.0;
  if (e != 0 || sigI[0] != 0) {
    sig = sigI[0].toDouble() / (8388608.0 * 2.0) + 0.5;
    e -= 126;
  }

  if (neg) {
    sig = -sig;
  }

  return ldexpf(sig, e);
}

// Multiplies a floating point value arg by the number 2 raised to the exp power.
double ldexpf(double arg, int exp) {
  double result = arg * pow(2, exp);
  return result;
}

ESCFirmware processFirmware(Uint8List payload) {
  int index = 1;
  ESCFirmware firmwarePacket = ESCFirmware();
  firmwarePacket.fw_version_major = payload[index++];
  firmwarePacket.fw_version_minor = payload[index++];
  // if (kDebugMode) {
  //   print("POCKET ID : $id");
  // }

  Uint8List hardwareBytes = Uint8List(30);
  int i = 0;
  while (payload[index] != 0) {
    hardwareBytes[i++] = payload[index++];
  }
  firmwarePacket.hardware_name = String.fromCharCodes(hardwareBytes);

  return firmwarePacket;
}

class ESCFirmware {
  ESCFirmware() {
    fw_version_major = 0;
    fw_version_minor = 0;
    hardware_name = "loading...";
  }
  int fw_version_major = 0;
  int fw_version_minor = 0;
  String hardware_name = "hw_name";
}

void listen() async {

  Singleton.rx?.value.listen((value) {
    // тут обработка полученных данных
    // if (kDebugMode) {
    //   print("Received data: $value");
    // }
    //first packet with length of the payload
    if(Singleton.indexForPacket == 0){
      firstPacket(value);
      Singleton.indexForPacket++;
      return;
    }

    //fore the next packets we receive we add the value to the list
    if(Singleton.indexForPacket >= 1){
      for (var element in value) {
        Singleton.list.add(element);
      }
    }

    // //TODO: crc16 check
    // int crc = 0;
    // if(list.length == payloadLength){
    //   List<int> listForCRC = [...list];
    //   listForCRC.insert(0, 74);
    //   listForCRC.insert(0, 2);
    //
    //   print("list for crc: ${listForCRC}");
    //
    //   Uint8List uintlist = Uint8List.fromList(listForCRC);
    //   crc = CRC16.crc16(uintlist, 0, uintlist.length);
    //   print("crc check sum: ${crc}");
    // }

    //if we have list.length equal payload Length + 3 we work with the packets
    //+3 because two last numbers are crc check and the last number is 3 which signalise end of message
    if(Singleton.list.length == Singleton.payloadLength + 3){
      //first byte of the list shows which command it is
      switch(Singleton.list[0]){
        case 0:
          workWithFirmWare(Singleton.list);
          break;
        case 4:
          workWithTelemetry(Singleton.list);
          break;
        case 47:
          workWithTelemetrySetup(Singleton.list);
          break;
        default:
          if (kDebugMode) {
            print("NEW NOT IMPLEMENTED COMMAND");
          }
          break;
      }
      Singleton.list.clear();
      Singleton.indexForPacket = 0; Singleton.payloadLength = 0; Singleton.packetLength = 0;
      return;
      //TODO: crc16 checksum
      // print(value);
      // int checksum = CRC16.crc16(Uint8List.fromList([value[0], value[1]]), 0, value.length - 1);
      //
      // print("Checksum: ${checksum}");
    }
    Singleton.indexForPacket++;
  });
}

void firstPacket(List<int> value) {
  Singleton.packetLength = value[0];
  if(Singleton.packetLength == 2){
    Singleton.payloadLength = value[1];
  } else if (Singleton.packetLength == 3){
    Singleton.payloadLength = (value[1] << 8) | value[2];
  }
  return;
}

void workWithFirmWare(List<int> value) {
  ESCFirmware firmwarePacket = ESCFirmware();

  Uint8List firmwarePacket1 = Uint8List.fromList(value);
  firmwarePacket = processFirmware(firmwarePacket1);

  var major = firmwarePacket.fw_version_major;
  var minor = firmwarePacket.fw_version_minor;
  var hardName = firmwarePacket.hardware_name;
  globalLogger.d("Firmware packet: major $major, minor $minor, hardware $hardName");
  Singleton.firmware = firmwarePacket;
}

void workWithTelemetrySetup(List<int> value){

  Singleton.telemetryPacket = processSetupValues(Uint8List.fromList(value));

  // Update map of ESC telemetry
  Singleton.telemetryMap[Singleton.telemetryPacket.vesc_id] = Singleton.telemetryPacket;

}

void workWithTelemetry(List<int> value) {
  Singleton.telemetryPacket = processTelemetry(Uint8List.fromList(value));

  // Update map of ESC telemetry
  Singleton.telemetryMap[Singleton.telemetryPacket.vesc_id] = Singleton.telemetryPacket;

}

void sendPacket(int command) async {
  Uint8List packet = simpleVESCRequest(command);

  // Request COMM_GET_VALUES_SETUP from the ESC
  if (!await sendBLEData(Singleton.tx, packet, true)) {
    globalLogger.e("_requestTelemetry() failed");
  } else {
    //print("Hello this is sendBLEData");
  }

  //print("after rx tx");
}

Widget logo(){
  return Expanded(
    flex: 15,
    child: Align(
      alignment: Alignment.topLeft,
      child: FractionallySizedBox(
        widthFactor: 0.19, // Adjust this value as needed
        heightFactor: 0.5, // Adjust this value as needed
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
            'assets/images/logo1.png',
          ),
        ),
      ),
    ),
  );
}


class SpeedFilter {
  final int size;
  final Queue<double> speedQueue;
  double threshold;

  SpeedFilter({required this.size, this.threshold = 1.0})
      : speedQueue = Queue<double>();

  double filter(double speed) {
    if (speedQueue.length == size) {
      speedQueue.removeFirst();
    }
    speedQueue.add(speed);

    double averageSpeed =
        speedQueue.reduce((a, b) => a + b) / speedQueue.length;
    return averageSpeed >= threshold ? averageSpeed : 0;
  }
}
