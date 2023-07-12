import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workproject/bleHelper.dart';
import 'dart:async';
import 'package:workproject/globalUtilities.dart';

// import '../Components/crc16.dart';
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
  // static Uint8List payload = new Uint8List(512);
  static ESCFirmware firmwarePacket = new ESCFirmware();
  static Map<int, ESCTelemetry> telemetryMap = new Map();
  BLEHelper bleHelper = new BLEHelper();
  late BluetoothService uartService;
  late BluetoothCharacteristic tx;
  late BluetoothCharacteristic rx;
  int index = 0;
  int payloadLength = 0;
  int packetLength = 0;
  List<int> list = [];


  @override
  void initState() {
    super.initState();
    checkLocationService();
    checkLocationPermission();
    
    if (widget.device != null){
      device = widget.device;
      print(device?.name);
      // take service and characteristics
      getServAndChar();
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
                flex: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(5),
                        child: Image(
                          image: AssetImage('assets/logo1.png'), width: 50, height: 50,
                        ),
                      ),
                      const Text(
                        "SyDev1",
                        style: TextStyle(
                          color: Color.fromRGBO(230, 230, 230, 100),
                          fontSize: 40
                        ),

                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 40, color: Color.fromRGBO(230, 230, 230, 100),),
                        onPressed: () {
                          // Handle menu button press
                        },
                      ),
                ]),
              ),
              //second row with template for speedometer
              Expanded(
                flex: 35,
                child: Row(
                  children: <Widget>[
                    // First column - 20%
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _createCell('Column 1'),
                        ],
                      ),
                    ),
                    // Second column - 40%
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _showSpeed(),
                        ],
                      ),
                    ),
                    // Third column - 40%
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Expanded(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "km/h",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color.fromRGBO(230, 230, 230, 100)
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _showBattery('Item 6'),
                        ],
                      ),
                    ),
                  ],
                )
              ),
              Expanded(
                flex: 54,
                  child: Padding(
                    child: Column (
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              //Voltage
                              Expanded(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2BB8C9),
                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded
                                  ),
                                  child: Padding(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'VOLTAGE',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white30,
                                          ),
                                        ),
                                        SizedBox(height: 20),  // Add some space between the two pieces of text
                                        Text(
                                          '$voltage V',
                                          style: const TextStyle(
                                            fontSize: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(top: 5),
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
                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded
                                  ),
                                  child: Padding(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CURRENT',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white30,
                                          ),
                                        ),
                                        SizedBox(height: 20),  // Add some space between the two pieces of text
                                        Text(
                                          '$current A',
                                          style: const TextStyle(
                                            fontSize: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(top: 5),
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
                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded
                                  ),
                                  child: Padding(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TEMPERATURE',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white30,
                                          ),
                                        ),
                                        SizedBox(height: 20),  // Add some space between the two pieces of text
                                        Text(
                                          '$temperature°C',
                                          style: const TextStyle(
                                            fontSize: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(top: 5),
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
                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded
                                  ),
                                  child: Padding(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MODE',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white30,
                                          ),
                                        ),
                                        SizedBox(height: 20),  // Add some space between the two pieces of text
                                        Text(
                                          '$mode',
                                          style: const TextStyle(
                                            fontSize: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(top: 5),
                                  )


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
                    padding: EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 8),
                  )
              )
              //third and fourth rows are for some other iformation like Voltage, Temperature, etc

            ],
          ),
        ),
      ),
    );
  }

  Widget _createCell(String text) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(2), // Add some space between cells
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black), // Create border
        ),
        child: Text(text),
      ),
    );
  }

  Widget _cellForData(int i){

    String textForCell;

    switch (i){
      case 0:
        textForCell = '$voltage V';
        break;
      case DATA_ID.CURRENT:
        textForCell = '$current A';
        break;
      case DATA_ID.TEMPERATURE:
        textForCell = '$temperature°C';
        break;
      case DATA_ID.MODE:
        textForCell = 'SPORT';
        break;
      default:
        textForCell = "zjf";
        break;
    }

    return Expanded(
      child:
      Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF2BB8C9),
          borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VOLTAGE',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white30,
              ),
            ),
            SizedBox(height: 20),  // Add some space between the two pieces of text
            Text(
              '$textForCell',
              style: const TextStyle(
                fontSize: 35,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendPacket() async {
    Uint8List packet = simpleVESCRequest(COMM_PACKET_ID.COMM_FW_VERSION.index);;

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

  void workWithTelemetrySetup(List<int> value){
    telemetryPacket = processSetupValues(Uint8List.fromList(value));

    // Update map of ESC telemetry
    telemetryMap[telemetryPacket.vesc_id] = telemetryPacket;
  }

  void workWithTelemetry(List<int> value) {
    telemetryPacket = processTelemetry(Uint8List.fromList(value));

    // Update map of ESC telemetry
    telemetryMap[telemetryPacket.vesc_id] = telemetryPacket;

  }

  void getServAndChar() async {
    List<BluetoothService>? services = await device?.discoverServices();

    // Обнаружение служб
    uartService = services!.firstWhere(
          (service) => service.uuid == Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
    );

    // Находим характеристики для RX и TX
    //transmit
    tx = uartService.characteristics.firstWhere(
          (c) => c.uuid == Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e"),
    );
    // receive
    rx = uartService.characteristics.firstWhere(
          (c) => c.uuid == Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e"),
    );
    try {
      if(rx.properties.notify == true){
        // await Future.delayed(Duration(seconds: 2));
        await rx.setNotifyValue(true);
      }
    } catch (e) {
      print("Failed to setup notifications: $e");
    }
    listen();
    sendPacket();
  }

  void listen() async {

    rx.value.listen((value) {
      // тут обработка полученных данных
      print("Received data: $value");
      //first packet with length of the payload
      if(index == 0){
        firstPacket(value);
        return;
      }

      //fore the next packets we receive we add the value to the list
      if(index >= 1){
        for (var element in value) {
          list.add(element);
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
      if(list.length == payloadLength + 3){
        //first byte of the list shows which command it is
        switch(list[0]){
          case 0:
            workWithFirmWare(list);
            break;
          case 4:
            workWithTelemetry(list);
            break;
          case 47:
            workWithTelemetrySetup(list);
            break;
          default:
            print("NEW NOT IMPLEMENTED COMMAND");
            break;
        }
        index = 0; payloadLength = 0; packetLength = 0;

        //TODO: crc16 checksum
        // print(value);
        // int checksum = CRC16.crc16(Uint8List.fromList([value[0], value[1]]), 0, value.length - 1);
        //
        // print("Checksum: ${checksum}");
      }
      index++;
    });
  }

  void firstPacket(List<int> value) {
    packetLength = value[0];
    if(packetLength == 2){
      payloadLength = value[1];
    } else if (packetLength == 3){
      payloadLength = (value[1] << 8) | value[2];
    }
    index++;
    return;
  }

  _showSpeed() {
    return Center(
          child: Text(
            '27',
            style: TextStyle(
                color: Color.fromRGBO(230, 230, 230, 100),
                fontSize: 140,
                fontWeight: FontWeight.w500
            ),
          ),
        );
  }

  _showBattery(String s) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Battery icon (background)
          Transform.rotate(
            angle: pi / 2,
            child: const Icon(
              Icons.battery_full,
              size: 100,
              color: Color.fromRGBO(230, 230, 230, 100),
            ),
          ),
          // Battery level text (foreground)
          Text(
            '$batteryLevel %',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromRGBO(0, 79, 99, 100),
              fontWeight: FontWeight.bold,
              fontSize: 55 * 0.4,
            ),
          ),
        ],
      ),
    );

  }

}
