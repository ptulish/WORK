
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workproject/bleHelper.dart';
import 'dart:math';
import 'dart:async';
import 'package:workproject/globalUtilities.dart';

import '../dataTypes.dart';



class MainScreen extends StatefulWidget {
  // const MainScreen({super.key});
  final BluetoothDevice? device;

  const MainScreen({Key? key, this.device}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainScreen createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  BluetoothDevice? device;
  bool isLocationServiceEnabled = false;
  bool isLocationPermissionGranted = false;
  int batteryLevel = 100;
  double voltage = 0.5;
  double current = 1.3;
  double temperature = 60.1;
  String mode = "Sport";
  String status = "Everything is okay";
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  String? deviceAddress;
  late BluetoothService targetService;
  static ESCTelemetry telemetryPacket = new ESCTelemetry();
  static Uint8List payload = new Uint8List(512);
  static ESCFirmware firmwarePacket = new ESCFirmware();
  static Map<int, ESCTelemetry> telemetryMap = new Map();
  BLEHelper bleHelper = new BLEHelper();



  @override
  void initState() {
    super.initState();
    checkLocationService();
    checkLocationPermission();
    if (widget.device != null){
      device = widget.device;
    }
    if(device != null){
      readServices();
    }
  }

  Future<bool> checkLocationService() async {
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled && isLocationPermissionGranted) {
      return true;
    } else {
      // Геопозиция отключена, показываем всплывающее окно
      showLocationServiceDisabledDialog();
      return false;
    }
  }
  Future<void> checkLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.status;
    setState(() {
      isLocationPermissionGranted =
          permissionStatus == PermissionStatus.granted;
    });
  }
  void showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Geoposition is off!'),
          content: const Text(
              'To use the app you have to enable bluetooth.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Закрыть приложение
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'App is off',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                Future.delayed(const Duration(seconds: 1), () => exit(0));
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Открыть настройки устройства
                Navigator.of(context).pop();
                openLocationSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }
  Future<void> openLocationSettings() async {
    AndroidIntent intent = const AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    checkLocationPermission(); // Проверяем разрешение на геопозицию при запуске приложения

    return MaterialApp(
      title: 'Grid Main Screen',
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 114, 143, 80),
        body:
        Padding(padding: const EdgeInsets.only(top: 23, left: 3, right: 3, bottom: 1),
          child: Column(
            children: [
              //first row with logo and template for battery
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child:
                        Padding(padding: const EdgeInsets.all(5),
                          //logo SYLENTS
                          child: SvgPicture.asset(
                            'assets/sylents-claim.svg',
                            width: 100, // Укажите требуемую ширину
                            height: 100, // Укажите требуемую высоту
                          ),
                          //logo as in presentation
                          // child: Image(
                          //   image: AssetImage('assets/logo.png'),
                          // ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Stack(
                          children: [
                            Center(
                              child:
                              Transform.rotate(angle: pi / 2, child: const Icon(
                                Icons.battery_full,
                                size: 100,
                                color: Colors.white,

                              ),
                              ),

                            ),
                            Center(
                              child: Text(
                                '$batteryLevel %',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color.fromRGBO(0, 79, 99, 100),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60 * 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //second row fith template for speedometer
              const Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    '8 km/h',
                    style: TextStyle(
                        color: Color.fromRGBO(230, 230, 230, 100),
                        fontSize: 90,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
              //third and fourth rows are for some other iformation like Voltage, Temperature, etc
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    //Voltage
                    Expanded(
                      child:
                      Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$voltage V',
                            style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Current
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$current A',
                            style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    //Temperature
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$temperature° С',
                            style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    //mode
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            mode,
                            style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //fifth row with status
              Expanded(
                child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2BB8C9),
                      borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
                    ),
                    child: Center(
                        child: Text(
                          'Status: $status',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        )
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void readServices() async {
    List<BluetoothService>? services = await device?.discoverServices();

    // Обнаружение служб
    BluetoothService? uartService = services?.firstWhere(
          (service) => service.uuid == Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
    );

    // Находим характеристики для RX и TX
    //transmit
    BluetoothCharacteristic? tx = uartService?.characteristics.firstWhere(
          (c) => c.uuid == Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e"),
    );
    // receive
    BluetoothCharacteristic? rx = uartService?.characteristics.firstWhere(
          (c) => c.uuid == Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e"),
    );

    // Проверяем, найдены ли характеристики
    if (tx == null || rx == null) {
      print("TX or RX characteristic not found");
      return;
    }
    try {
      if(rx.properties.notify == true){
        // await Future.delayed(Duration(seconds: 2));
        await rx.setNotifyValue(true);
      }
    } catch (e) {
      print("Failed to setup notifications: $e");
    }
    int index = 0;
    int payloadLength = 0;
    int packetLength = 0;
    List<int> list = [];

    rx.value.listen((value) {
      // тут обработка полученных данных
      print("Received data: $value");
      if(index == 0){
        packetLength = value[0];
        if(packetLength == 2){
          payloadLength = value[1];
        } else if (packetLength == 3){
          payloadLength = (value[1] << 8) | value[2];
        }
        index++;
        return;
      }

      if(index >= 1){
        value.forEach((element) {
          list.add(element);
        });
      }

      if(list.length == payloadLength + 3){
        switch(list[0]){
          case 1:
            workWithFirmWare(list);
            break;
          case 4:
            workWithTelemetry(list);
            break;
          default:
            print("NEW NOT IMPLEMENTED COMMAND");
            break;
        }
        index = 0; payloadLength = 0; packetLength = 0;
      }
      index++;

    });


    Uint8List packet = simpleVESCRequest(COMM_PACKET_ID.COMM_GET_VALUES.index);;

    // Request COMM_GET_VALUES_SETUP from the ESC
    if (!await sendBLEData(tx, packet, true)) {
      globalLogger.e("_requestTelemetry() failed");
    } else {
      print("Hello this is sendBLEData");
    }

    print("after rx tx");
  }

  void workWithFirmWare(List<int> value) {

    Uint8List firmwarePacket1 = Uint8List.fromList(value);
    firmwarePacket = processFirmware(firmwarePacket1);

    var major = firmwarePacket.fw_version_major;
    var minor = firmwarePacket.fw_version_minor;
    var hardName = firmwarePacket.hardware_name;
    globalLogger.d("Firmware packet: major $major, minor $minor, hardware $hardName");

  }

  void workWithTelemetry(List<int> value) {
    telemetryPacket = processSetupValues(Uint8List.fromList(value));

    // Update map of ESC telemetry
    telemetryMap[telemetryPacket.vesc_id] = telemetryPacket;

  }

}
// void getPosition() async {
//   try {
//     // Position position = await Geolocator.getCurrentPosition(
//     //   desiredAccuracy: LocationAccuracy.best,
//     // );
//
//     // double latitude = position.latitude;
//     // double longitude = position.longitude;
//     //
//     // if (kDebugMode) {
//     //   print('Latitude: $latitude');
//     //   print('Longitude: $longitude');
//     // }
//   } catch (e) {
//     // Обработка ошибок
//     if(kDebugMode) {
//       print('Error: $e');
//     }
//   }
// }
// List<BluetoothService> services = await device.discoverServices();
// BluetoothService uartService = servisec




// void vonsk8(){
//   escRXDataSubscription = theRXCharacteristic.value.listen((value) {
//
//     // If we have the TCP Socket server running and a client connected forward the data
//     if(serverTCPSocket != null && clientTCPSocket != null) {
//       //globalLogger.wtf("ESC Data $value");
//       clientTCPSocket.add(value);
//       return;
//     }
//
//     // BLE data received
//     if (bleHelper.processIncomingBytes(value) > 0){
//
//       //Time to process the packet
//       int packetID = bleHelper.getPayload()[0];
//       if (packetID == COMM_PACKET_ID.COMM_FW_VERSION.index) {
//         ///Firmware Packet
//         firmwarePacket = escHelper.processFirmware(bleHelper.getPayload());
//
//         // Flag the reception of an init message
//         initMsgESCVersion = true;
//
//         // Analyze
//         var major = firmwarePacket.fw_version_major;
//         var minor = firmwarePacket.fw_version_minor;
//         var hardName = firmwarePacket.hardware_name;
//         globalLogger.d("Firmware packet: major $major, minor $minor, hardware $hardName");
//
//         setState(() {
//           isESCResponding = true;
//         });
//
//
//         bleHelper.resetPacket(); //Be ready for another packet
//
//         // Check if compatible firmware
//         if (major == 5 && minor == 1) {
//           escFirmwareVersion = ESC_FIRMWARE.FW5_1;
//         } else if (major == 5 && minor == 2) {
//           escFirmwareVersion = ESC_FIRMWARE.FW5_2;
//         } else if (major == 5 && minor == 3) {
//           escFirmwareVersion = ESC_FIRMWARE.FW5_3;
//         } else {
//           escFirmwareVersion = ESC_FIRMWARE.UNSUPPORTED;
//         }
//         if(escFirmwareVersion == ESC_FIRMWARE.UNSUPPORTED) {
//           // Stop the init message sequencer
//           _initMsgSequencer?.cancel();
//           _initMsgSequencer = null;
//           initMsgSqeuencerCompleted = true;
//
//           // Remove communicating with ESC dialog
//           if (Navigator.of(context).canPop()) {
//             Navigator.of(context).pop();
//           }
//
//           // Notify user we are in invalid firmware land
//           _alertInvalidFirmware("Firmware: $major.$minor\nHardware: $hardName");
//
//           return;
//           //TODO: not going to force the user to disconnect? _bleDisconnect();
//         }
//
//       }
//       else if ( packetID == DieBieMSHelper.COMM_GET_BMS_CELLS ) {
//         // Update SmartBMS Telemetry with Cell Data
//         dieBieMSTelemetry = dieBieMSHelper.processCells(bleHelper.getPayload());
//
//         // Publish SmartBMS Telemetry
//         bmsTelemetryStream.add(dieBieMSTelemetry);
//
//         bleHelper.resetPacket(); //Prepare for next packet
//       }
//       else if (packetID == COMM_PACKET_ID.COMM_GET_VALUES_SETUP.index) {
//         ///Telemetry packet
//         telemetryPacket = escHelper.processSetupValues(bleHelper.getPayload());
//
//         // Update map of ESC telemetry
//         telemetryMap[telemetryPacket.vesc_id] = telemetryPacket;
//
//         // Update telemetryStream for those who are subscribed
//         telemetryStream.add(telemetryPacket);
//
//         if(controller.index == controllerViewRealTime) { //Only re-draw if we are on the real time data tab
//           setState(() { //Re-drawing with updated telemetry data
//           });
//         }
//
//         // Watch here for all fault codes received. Populate an array with time and fault for display to user
//         if ( telemetryPacket.fault_code != mc_fault_code.FAULT_CODE_NONE ) {
//           globalLogger.w("WARNING! Fault code received! ${telemetryPacket.fault_code}");
//         }
//
//         // Prepare for the next packet
//         bleHelper.resetPacket();
//       }
//       else if ( packetID == COMM_PACKET_ID.COMM_GET_VALUES.index ) {
//         if(_showDieBieMS) {
//           // Parse DieBieMS GET_VALUES packet - A shame they share the same ID as ESC values
//           DieBieMSTelemetry parsedTelemetry = dieBieMSHelper.processTelemetry(bleHelper.getPayload(), smartBMSCANID);
//
//           // Make sure we parsed what we are expecting
//           if (parsedTelemetry != null) {
//             /// Automatically request cell data from DieBieMS
//             var byteData = new ByteData(10);
//             byteData.setUint8(0, 0x02); // Start of packet
//             byteData.setUint8(1, 3); // Packet length
//             byteData.setUint8(2, COMM_PACKET_ID.COMM_FORWARD_CAN.index);
//             byteData.setUint8(3, smartBMSCANID); //CAN ID
//             byteData.setUint8(4, DieBieMSHelper.COMM_GET_BMS_CELLS);
//             int checksum = CRC16.crc16(byteData.buffer.asUint8List(), 2, 3);
//             byteData.setUint16(5, checksum);
//             byteData.setUint8(7, 0x03); // End of packet
//
//             sendBLEData(theTXCharacteristic, byteData.buffer.asUint8List(), true).then((sendResult){
//               if (!sendResult) {
//                 globalLogger.w("Smart BMS cell data request failed");
//               }
//             });
//           }
//         }
//
//         // Prepare for the next packet
//         bleHelper.resetPacket();
//
//       } else if ( packetID == COMM_PACKET_ID.COMM_PING_CAN.index ) {
//         ///Ping CAN packet
//         globalLogger.d("Ping CAN packet received! ${bleHelper.lenPayload} bytes");
//
//         // Flag the reception of an init message
//         initMsgESCDevicesCAN = true;
//
//         // Populate a fresh _validCANBusDeviceIDs array
//         _validCANBusDeviceIDs.clear();
//         for (int i = 1; i < bleHelper.lenPayload; ++i) {
//           if (bleHelper.getPayload()[i] != 0) {
//             globalLogger.d("CAN Device Found at ID ${bleHelper
//                 .getPayload()[i]}. Is it an ESC? Stay tuned to find out more...");
//             _validCANBusDeviceIDs.add(bleHelper.getPayload()[i]);
//           }
//         }
//
//         // Prepare for yet another packet
//         bleHelper.resetPacket();
//       } else if ( packetID == COMM_PACKET_ID.COMM_NRF_START_PAIRING.index ) {
//         globalLogger.d("COMM_PACKET_ID = COMM_NRF_START_PAIRING");
//         switch (bleHelper.getPayload()[1]) {
//           case 0:
//             globalLogger.d("Pairing started");
//             startStopTelemetryTimer(true); //Stop the telemetry timer
//
//             showDialog(
//               barrierDismissible: false,
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text("nRF Quick Pair"),
//                   content: SizedBox(
//                     height: 100, child: Column(children: <Widget>[
//                     CircularProgressIndicator(),
//                     SizedBox(height: 10,),
//                     Text(
//                         "Think fast! You have 10 seconds to turn on your remote.")
//                   ],),
//                   ),
//                 );
//               },
//             );
//             break;
//           case 1:
//             globalLogger.d("Pairing Successful");
//             Navigator.of(context).pop(); //Pop Quick Pair initial dialog
//
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text("nRF Quick Pair"),
//                   content: Text(
//                       "Pairing Successful! Your remote is now live. Congratulations =)"),
//                 );
//               },
//             );
//             break;
//           case 2:
//             globalLogger.d("Pairing timeout");
//             Navigator.of(context).pop(); //Pop Quick Pair initial dialog
//
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text("nRF Quick Pair"),
//                   content: Text(
//                       "Oh bummer, a timeout. We didn't find a remote this time but you are welcome to try again."),
//                 );
//               },
//             );
//             break;
//           default:
//             globalLogger.e("ERROR: Pairing unknown payload");
//             Navigator.of(context).pop(); //Pop Quick Pair initial dialog
//         }
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_SET_MCCONF.index ) {
//         globalLogger.d("COMM_PACKET_ID = COMM_SET_MCCONF");
//         //logger.d("COMM_PACKET_ID.COMM_SET_MCCONF: ${bleHelper.getPayload().sublist(0,bleHelper.lenPayload)}");
//         // Show dialog
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Success"),
//               content: Text("ESC configuration saved successfully!"),
//             );
//           },
//         );
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_SET_MCCONF_TEMP_SETUP.index ) {
//         globalLogger.d("COMM_PACKET_ID = COMM_SET_MCCONF_TEMP_SETUP");
//         genericAlert(context, "Success", Text("Profile set successfully!"), "OK" );
//         requestMCCONF();
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_GET_MCCONF.index) {
//         ///ESC Motor Configuration
//         escMotorConfiguration = escHelper.processMCCONF(bleHelper.getPayload(), escFirmwareVersion); //bleHelper.payload.sublist(0,bleHelper.lenPayload);
//
//         // Publish MCCONF to potential subscriber
//         mcconfStream.add(escMotorConfiguration);
//
//         //NOTE: for debug & testing
//         //ByteData serializedMcconf = escHelper.serializeMCCONF(escMotorConfiguration);
//         //MCCONF refriedMcconf = escHelper.processMCCONF(serializedMcconf.buffer.asUint8List());
//         //globalLogger.wtf("Break for MCCONF: $escMotorConfiguration");
//
//         if (escMotorConfiguration.si_battery_ah == null) {
//           // Stop the init message sequencer
//           _initMsgSequencer?.cancel();
//           _initMsgSequencer = null;
//           initMsgSqeuencerCompleted = true;
//
//           // Remove communicating with ESC dialog
//           if (Navigator.of(context).canPop()) {
//             Navigator.of(context).pop();
//           }
//
//           // Show dialog
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text("Incompatible ESC"),
//                 content: Text("The selected ESC did not return a valid Motor Configuration"),
//               );
//             },
//           );
//         } else {
//           // Flag the reception of an init message
//           initMsgESCMotorConfig = true;
//
//           // Save FreeSK8 user settings from received MCCONF
//           globalLogger.d("Updating application settings specific from MCCONF");
//           widget.myUserSettings.settings.batterySeriesCount = escMotorConfiguration.si_battery_cells;
//           switch (escMotorConfiguration.si_battery_type) {
//             case BATTERY_TYPE.BATTERY_TYPE_LIIRON_2_6__3_6:
//               widget.myUserSettings.settings.batteryCellMinVoltage = 2.6;
//               widget.myUserSettings.settings.batteryCellMaxVoltage = 3.6;
//               break;
//             default:
//               widget.myUserSettings.settings.batteryCellMinVoltage = 3.0;
//               widget.myUserSettings.settings.batteryCellMaxVoltage = 4.2;
//               break;
//           }
//
//           widget.myUserSettings.settings.wheelDiameterMillimeters = (doublePrecision(escMotorConfiguration.si_wheel_diameter, 3) * 1000).toInt();
//           //TODO: Take note of this importance: globalLogger.wtf("wheel diameter mm maths ${(doublePrecision(escMotorConfiguration.si_wheel_diameter, 3) * 1000).toInt()} vs ${(escMotorConfiguration.si_wheel_diameter * 1000).toInt()}");
//
//           widget.myUserSettings.settings.motorPoles = escMotorConfiguration.si_motor_poles;
//           widget.myUserSettings.settings.maxERPM = escMotorConfiguration.l_max_erpm;
//           widget.myUserSettings.settings.gearRatio = doublePrecision(escMotorConfiguration.si_gear_ratio, 2);
//
//           widget.myUserSettings.saveSettings();
//         }
//
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_GET_MCCONF_DEFAULT.index) {
//
//         setState(() { // setState so focWizard receives updated MCCONF Defaults
//           //TODO: focWizard never uses escMotorConfigurationDefaults
//           escMotorConfigurationDefaults = bleHelper.getPayload().sublist(0,bleHelper.lenPayload);
//         });
//         globalLogger.d("Oof.. MCCONF_DEFAULT: $escMotorConfigurationDefaults");
//
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_GET_APPCONF.index) {
//         globalLogger.d("COMM_PACKET_ID = COMM_GET_APPCONF");
//
//         ///ESC Application Configuration
//         escApplicationConfiguration = escHelper.processAPPCONF(bleHelper.getPayload(), escFirmwareVersion);
//
//         // Publish APPCONF to subscribers
//         appconfStream.add(escApplicationConfiguration);
//
//         if (escApplicationConfiguration.imu_conf.sample_rate_hz == null) {
//           // Show dialog
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text("Incompatible ESC"),
//                 content: Text("The selected ESC did not return a valid Input Configuration"),
//               );
//             },
//           );
//         }
//
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_DETECT_APPLY_ALL_FOC.index) {
//         globalLogger.d("COMM_DETECT_APPLY_ALL_FOC packet received");
//         // Handle FOC detection results
//         globalLogger.d(bleHelper.getPayload().sublist(0,bleHelper.lenPayload)); //[58, 0, 1]
//         // * @return
//         // * >=0: Success, see conf_general_autodetect_apply_sensors_foc codes
//         // * 2: Success, AS5147 detected successfully
//         // * 1: Success, Hall sensors detected successfully
//         // * 0: Success, No sensors detected and sensorless mode applied successfully
//         // * -10: Flux linkage detection failed
//         // * -1: Detection failed
//         // * -50: CAN detection timed out
//         // * -51: CAN detection failed
//         var byteData = new ByteData.view(bleHelper.getPayload().buffer);
//         int resultFOCDetection = byteData.getInt16(1);
//
//         Navigator.of(context).pop(); //Pop away the FOC wizard Loading Overlay
//
//         String resultText = "";
//         switch(resultFOCDetection) {
//           case 2:
//             resultText = "AS5147 encoder detected successfully";
//             break;
//           case 1:
//             resultText = "Hall sensors detected successfully";
//             break;
//           case 0:
//             resultText = "No sensors detected, sensorless mode applied successfully";
//             break;
//           case -1:
//             resultText = "Detection failed";
//             break;
//           case -10:
//             resultText = "Flux linkage detection failed";
//             break;
//           case -50:
//             resultText = "CAN detection timed out";
//             break;
//           case -51:
//             resultText = "CAN detection failed";
//             break;
//           default:
//             if (resultFOCDetection > 0) {
//               resultText = "Success ($resultFOCDetection)";
//             }
//             else {
//               resultText = "Unknown response from ESC ($resultFOCDetection)";
//             }
//         }
//         globalLogger.d("COMM_DETECT_APPLY_ALL_FOC: $resultText");
//         if (resultFOCDetection >= 0) {
//           Navigator.of(context).pop(); //Pop away the FOC wizard on success
//         }
//         // Show dialog
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("FOC Wizard"),
//               content: Text("${resultFOCDetection >= 0 ? "Successful detection!" : "Detection failed."}\n\n$resultText"),
//             );
//           },
//         );
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_GET_DECODED_PPM.index) {
//
//         int valueNow = buffer_get_int32(bleHelper.getPayload(), 1);
//         int msNow = buffer_get_int32(bleHelper.getPayload(), 5);
//         //globalLogger.d("Decoded PPM packet received: value $valueNow, milliseconds $msNow");
//
//         inputCalibration.ppmMillisecondsNow = msNow;
//         inputCalibration.ppmValueNow = valueNow;
//
//         // Publish Calibration data to Subscribers
//         calibrationStream.add(inputCalibration);
//
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_GET_DECODED_ADC.index) {
//
//         double levelNow = buffer_get_float32(bleHelper.getPayload(), 1, 1000000.0);
//         double voltageNow = buffer_get_float32(bleHelper.getPayload(), 5, 1000000.0);
//         double level2Now = buffer_get_float32(bleHelper.getPayload(), 9, 1000000.0);
//         double voltage2Now = buffer_get_float32(bleHelper.getPayload(), 13, 1000000.0);
//         //globalLogger.d("Decoded ADC packet received: level $levelNow, voltage $voltageNow, level2 $level2Now, voltage2 $voltage2Now");
//
//         inputCalibration.adcLevelNow = levelNow;
//         inputCalibration.adcLevel2Now = level2Now;
//         inputCalibration.adcVoltageNow = voltageNow;
//         inputCalibration.adcVoltage2Now = voltage2Now;
//
//         // Publish Calibration data to subscribers
//         calibrationStream.add(inputCalibration);
//
//         bleHelper.resetPacket();
//       } else if (packetID == COMM_PACKET_ID.COMM_PRINT.index) {
//
//         int stringLength = bleHelper.getMessage()[1] - 1;
//         String messageFromESC = new String.fromCharCodes(bleHelper.getMessage().sublist(3, 3 + stringLength));
//         globalLogger.i("ESC::COMM_PRINT: $messageFromESC");
//         bleHelper.resetPacket();
//
//       } else if (packetID == COMM_PACKET_ID.COMM_SET_APPCONF.index) {
//
//         if (inputCalibration.ppmCalibrationStarting != null && inputCalibration.ppmCalibrationStarting) {
//           globalLogger.d("PPM Calibration is Ready");
//           genericAlert(context, "Calibration", Text("Calibration Instructions:\nMove input to full brake, full throttle then leave in the center\n\nPlease ensure the wheels are off the ground in case something goes wrong. Press OK when ready."), "OK");
//           inputCalibration.ppmCalibrationStarting = null;
//           inputCalibration.ppmCalibrationRunning = true;
//           calibrationStream.add(inputCalibration); // Publish update
//         } else if (inputCalibration.ppmCalibrationRunning != null && !inputCalibration.ppmCalibrationRunning) {
//           globalLogger.d("PPM Calibration has completed");
//           genericAlert(context, "Calibration", Text("Calibration Completed"), "OK");
//           inputCalibration.ppmCalibrationStarting = null;
//           inputCalibration.ppmCalibrationRunning = null;
//           calibrationStream.add(inputCalibration); // Publish update
//         } else if (inputCalibration.adcCalibrationStarting != null && inputCalibration.adcCalibrationStarting) {
//           globalLogger.d("ADC Calibration is Ready");
//           genericAlert(context, "Calibration", Text("Calibration Instructions:\nMove input to full brake, full throttle then leave in the center\n\nPlease ensure the wheels are off the ground in case something goes wrong. Press OK when ready."), "OK");
//           inputCalibration.adcCalibrationStarting = null;
//           inputCalibration.adcCalibrationRunning = true;
//           calibrationStream.add(inputCalibration); // Publish update
//         } else if (inputCalibration.adcCalibrationRunning != null && !inputCalibration.adcCalibrationRunning) {
//           globalLogger.d("ADC Calibration has completed");
//           genericAlert(context, "Calibration", Text("Calibration Completed"), "OK");
//           inputCalibration.adcCalibrationStarting = null;
//           inputCalibration.adcCalibrationRunning = null;
//           calibrationStream.add(inputCalibration); // Publish update
//         } else {
//           globalLogger.d("Application Configuration Saved Successfully");
//           genericAlert(context, "Success", Text("Application configuration set"), "Excellent");
//         }
//
//         bleHelper.resetPacket();
//
//       } else if (packetID == COMM_PACKET_ID.COMM_GET_VALUES_SELECTIVE.index) {
//         //NOTE: Useful data could be parsed from these packets but is not necessary
//         bleHelper.resetPacket();
//       } else {
//         globalLogger.e("Unsupported packet ID: $packetID");
//         globalLogger.e("Unsupported packet Message: ${bleHelper.getMessage().sublist(0,bleHelper.endMessage)}");
//         bleHelper.resetPacket();
//       }
//     }
//   });
//
// }

// void readServices() async {
//   List<BluetoothService>? services = await device?.discoverServices();
//   services?.forEach((service) {
//     // Печать информации о службе
//     print("Device id: ${service.deviceId}");
//     print("Service.uuid: ${service.uuid}");
//     service.characteristics.forEach((characteristic) {
//       // Печать информации о характеристике
//       print("characteristic.lastValue: ${characteristic.lastValue}");
//       print("Characteristic: ${characteristic.uuid}");
//     });
//   });
//
//
//   // Обнаружение служб
//   // Обнаружение служб
//   // List<BluetoothService>? services = await device?.discoverServices();
//   BluetoothService? uartService = services?.firstWhere(
//         (service) => service.uuid == Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
//   );
//
//
//   print(services?.length);
//
//   // Находим характеристики для RX и TX
//   BluetoothCharacteristic? rx = uartService?.characteristics.firstWhere(
//         (c) => c.uuid == Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e"),
//   );
//   BluetoothCharacteristic? tx = uartService?.characteristics.firstWhere(
//         (c) => c.uuid == Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e"),
//   );
//
// // Проверяем, найдены ли характеристики
//   if (tx == null || rx == null) {
//     print("TX or RX characteristic not found");
//     return;
//   }
//
//
//   //
//   // await requestFirmwareVersion(rx);
//
//
//   // Uint8List dataToSend = simpleVESCRequest(COMM_PACKET_ID.COMM_FW_VERSION.index);
//   //
//   // BluetoothCharacteristic txCharacteristic = rx; // The TX Characteristic of your Bluetooth connection
//   // bool success = await sendBLEData(txCharacteristic, dataToSend, false);
//   //
//   // await Future.delayed(const Duration(milliseconds: 5000), () {});
//   //
//   //
//   // if (success) {
//   //   print("Data was sent successfully");
//   // } else {
//   //   print("Failed to send data");
//   // }
//
//
//
//   print("after sending");
//
//   print("uuid: ${tx.uuid}, propert: ${tx.properties}, ");
//
//   try {
//     if(tx.properties.notify == true){
//       // await Future.delayed(Duration(seconds: 2));
//       await tx.setNotifyValue(true);
//     }
//   } catch (e) {
//     print("Failed to setup notifications: $e");
//   }
//
//   // await tx.setNotifyValue(true);
//   tx.value.listen((value) {
//     // тут обработка полученных данных
//     print("Received data: $value");
//   });
//
//   Uint8List packet = simpleVESCRequest(COMM_PACKET_ID.COMM_GET_VALUES_SETUP.index);
//
// // Request COMM_GET_VALUES_SETUP from the ESC
//   if (!await sendBLEData(rx, packet, true)) {
//     globalLogger.e("_requestTelemetry() failed");
//   }
//
//   print("after rx tx");
//
// //
// //     // Поиск нужной службы
// //     //suche nach bestimmte service
// //     for (BluetoothService service in services!) {
// //       if (service.uuid.toString() == "00001801-0000-1000-8000-00805f9b34fb") {
// //         targetService = service;
// //         print("object");
// //         break;
// //       }
// //     }
// //
// //     if(targetService == null) {
// //       // Обработка случая, когда служба не найдена.
// //       print('Не удалось найти целевую службу');
// //       return;
// //     }
// //
// //     BluetoothCharacteristic? targetCharacteristic;
// //
// // // Поиск нужной характеристики
// // //     for (BluetoothCharacteristic characteristic in targetService.characteristics) {
// // //       if (characteristic.uuid.toString() == "6e400001-b5a3-f393-e0a9-e50e24dcca9e") {
// // //         targetCharacteristic = characteristic;
// // //         print("hi");
// // //         break;
// // //       }
// // //     }
// //
// //     // if(targetCharacteristic == null) {
// //     //   // Обработка случая, когда характеристика не найдена.
// //     //   print('Не удалось найти целевую характеристику');
// //     //   return;
// //     // }
// //
// //     // Подписка на обновления значений характеристики
// //     await targetCharacteristic?.setNotifyValue(true);
// //     print(targetCharacteristic?.setNotifyValue(true));
// //     targetCharacteristic?.value.listen((value) {
// //       // Обработка полученных данных
// //       print('Полученные данные: $value');
// //     });
//
//
// // Теперь у вас есть характеристика RX (targetCharacteristic), которую вы можете использовать
// }

