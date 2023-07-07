



import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import 'Components/crc16.dart';
import 'dataTypes.dart';

Logger globalLogger = Logger(printer: PrettyPrinter(methodCount: 0), filter: MyFilter());

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

Uint8List simpleVESCRequest(int messageIndex, {int? optionalCANID}) {
  bool sendCAN = optionalCANID != null;
  var byteData = new ByteData(sendCAN ? 8:6); //<start><payloadLen><packetID><crc1><crc2><end>
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


Future<bool> sendBLEData(BluetoothCharacteristic txCharacteristic, Uint8List data, bool withoutResponse) async
{
  int errorLimiter = 30;
  int packetLength = data.length;
  int bytesSent = 0;
  while (bytesSent < packetLength) {
    int endByte = bytesSent + 20;
    if (endByte > packetLength) {
      endByte = packetLength;
    }
    try {
      await txCharacteristic.write(
          data.buffer.asUint8List().sublist(bytesSent, endByte),
          withoutResponse: true);
    } on PlatformException catch (err) {
      //TODO: Assuming err.code will always be "write_characteristic_error"
      if (--errorLimiter == 0) {
        globalLogger.e("sendBLEData: Write to characteristic exhausted all attempts. Data not sent. ${txCharacteristic.toString()}");
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
  ESCTelemetry telemetryPacket = new ESCTelemetry();

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
  ESCTelemetry telemetryPacket = new ESCTelemetry();

  print("PAyload: ${payload}");
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

  print("temp_mos: ${telemetryPacket.temp_mos}\n"
      "temp_motor ${telemetryPacket.temp_motor}\n"
      "current_motor: ${telemetryPacket.current_motor}\n"
      "current_in: ${telemetryPacket.current_in}\n"
      "foc_id: ${telemetryPacket.foc_id}\n"
      "foc_iq: ${telemetryPacket.foc_iq}\n"
      "duty_now: ${telemetryPacket.duty_now}\n"
      "rpm: ${telemetryPacket.rpm}\n"
      // "speed: ${telemetryPacket.speed}"
      "v_in: ${telemetryPacket.v_in}\n"
      // "battery_level: ${telemetryPacket.battery_level}"
      "amp_hours: ${telemetryPacket.amp_hours}\n"
      "amp_hours_charged: ${telemetryPacket.amp_hours_charged}\n"
      "watt_hours: ${telemetryPacket.watt_hours}\n"
      "watt_hours_charged: ${telemetryPacket.watt_hours_charged}\n"
      "tachometer: ${telemetryPacket.tachometer}\n"
      "tachometer_abs: ${telemetryPacket.tachometer_abs}\n"
      "position: ${telemetryPacket.position}\n"
      "fault_code: ${telemetryPacket.fault_code}\n"
      "vesc_id: ${telemetryPacket.vesc_id}\n"
      "num_vescs: ${telemetryPacket.num_vescs}\n"
      "battery_wh: ${telemetryPacket.battery_wh}\n"
      "vd: ${telemetryPacket.vd}\n"
      "vq: ${telemetryPacket.vq}\n"
      "temp_mos1: ${telemetryPacket.temp_mos_1}\n"
      "temp_mos2: ${telemetryPacket.temp_mos_2}\n"
      "temp_mos3: ${telemetryPacket.temp_mos_3}\n"
  );

  print("index: $index, payload: ${payload.length}");

  return telemetryPacket;
}
int buffer_get_int16(Uint8List buffer, int index) {
  var byteData = new ByteData.view(buffer.buffer);
  return byteData.getInt16(index);
}

int buffer_get_uint16(Uint8List buffer, int index) {
  var byteData = new ByteData.view(buffer.buffer);
  return byteData.getUint16(index);
}

int buffer_get_int32(Uint8List buffer, int index) {
  var byteData = new ByteData.view(buffer.buffer);
  return byteData.getInt32(index);
}

int buffer_get_uint32(Uint8List buffer, int index) {
  var byteData = new ByteData.view(buffer.buffer);
  return byteData.getUint32(index);
}

int buffer_get_uint64(Uint8List buffer, int index, [Endian endian = Endian.big]) {
  var byteData = new ByteData.view(buffer.buffer);
  return byteData.getUint64(index, endian);
}

double buffer_get_float16(Uint8List buffer, int index, double scale) {
  return buffer_get_int16(buffer, index) / scale;
}

double buffer_get_float32(Uint8List buffer, int index, double scale) {
  return buffer_get_int32(buffer, index) / scale;
}

double buffer_get_float32_auto(Uint8List buffer, int index) {
  Uint32List res = new Uint32List(1);
  res[0] = buffer_get_uint32(buffer, index);

  int e = (res[0] >> 23) & 0xFF;
  Uint32List sig_i = new Uint32List(1);
  sig_i[0] = res[0] & 0x7FFFFF;
  int neg_i = res[0] & (1 << 31);
  bool neg = neg_i > 0 ? true : false;

  double sig = 0.0;
  if (e != 0 || sig_i[0] != 0) {
    sig = sig_i[0].toDouble() / (8388608.0 * 2.0) + 0.5;
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
  int id = payload[0];
  int index = 1;
  ESCFirmware firmwarePacket = new ESCFirmware();
  firmwarePacket.fw_version_major = payload[index++];
  firmwarePacket.fw_version_minor = payload[index++];
  print("POCKET ID : $id");

  Uint8List hardwareBytes = new Uint8List(30);
  int i = 0;
  while (payload[index] != 0) {
    hardwareBytes[i++] = payload[index++];
  }
  firmwarePacket.hardware_name = new String.fromCharCodes(hardwareBytes);

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
