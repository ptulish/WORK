import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workproject/globalUtilities.dart';

class Singleton{
  // Private constructor
  Singleton._internal();

  static final Singleton _singleton = Singleton._internal();

  factory Singleton() {
    return _singleton;
  }


  static StreamSubscription<Position>? positionStreamSubscription;
  static BluetoothCharacteristic? rx;
  static BluetoothCharacteristic? tx;
  static BluetoothService? uartService;
  static int indexForPacket = 0;
  static List<int> list = [];
  static int payloadLength = 0;
  static int packetLength = 0;
  static ESCFirmware? firmware;
  static ESCTelemetry telemetryPacket = new ESCTelemetry();

  static String topRight = 'Input Current';
  static String topLeft = 'Power';
  static String bottomRight = 'MOSFET Temperature';
  static String bottomLeft = 'Input Voltage';

  static final StreamController<Map<int, ESCTelemetry>> _mapController = StreamController.broadcast();

  static Map<int, ESCTelemetry> _telemetryMap = {};
  static Map<int, ESCTelemetry> get telemetryMap => _telemetryMap;

  static set telemetryMap(Map<int, ESCTelemetry> value) {
    _telemetryMap = value;
    _mapController.add(_telemetryMap); // Emit the new map value
  }

  static Stream<Map<int, ESCTelemetry>> get telemetryStream => _mapController.stream;
}