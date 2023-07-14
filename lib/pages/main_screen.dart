import 'dart:math';import 'package:flutter/foundation.dart';import 'package:flutter/material.dart';import 'dart:io';import 'package:android_intent/android_intent.dart';import 'package:flutter_blue_plus/flutter_blue_plus.dart';import 'package:fluttertoast/fluttertoast.dart';import 'package:geolocator/geolocator.dart';import 'package:permission_handler/permission_handler.dart';import 'package:workproject/bleHelper.dart';import 'dart:async';import 'package:workproject/globalUtilities.dart';import 'package:workproject/pages/menu_screen.dart';// import '../Components/crc16.dart';import '../classes/singleton.dart';import '../dataTypes.dart';class MainScreen extends StatefulWidget {  // const MainScreen({super.key});  final BluetoothDevice? device;  const MainScreen({Key? key, this.device}) : super(key: key);  @override  // ignore: library_private_types_in_public_api  _MainScreen createState() => _MainScreen();}class _MainScreen extends State<MainScreen> {  BluetoothDevice? device;  bool isLocationServiceEnabled = false;  bool isLocationPermissionGranted = false;  int batteryLevel = 100;  double voltage = 0.5;  double current = 1.3;  double temperature = 60.1;  String mode = "Sport";  String status = "Everything is okay";  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;  String? deviceAddress;  late BluetoothService targetService;  BLEHelper bleHelper = new BLEHelper();  late BluetoothService uartService;  late BluetoothCharacteristic tx;  late BluetoothCharacteristic rx;  int index = 0;  int payloadLength = 0;  int packetLength = 0;  List<int> list = [];  @override  void initState() {    super.initState();    checkLocationService();    checkLocationPermission();        if (widget.device != null){      device = widget.device;      print(device?.name);      Timer.periodic(const Duration(seconds: 1), (Timer t) => sendPacket(COMM_PACKET_ID.COMM_GET_VALUES.index));    }  }  Future<bool> checkLocationService() async {    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();    if (isLocationServiceEnabled && isLocationPermissionGranted) {      return true;    } else {      // Геопозиция отключена, показываем всплывающее окно      showLocationServiceDisabledDialog();      return false;    }  }  Future<void> checkLocationPermission() async {    PermissionStatus permissionStatus = await Permission.location.status;    setState(() {      isLocationPermissionGranted =          permissionStatus == PermissionStatus.granted;    });  }  void showLocationServiceDisabledDialog() {    showDialog(      context: context,      barrierDismissible: false,      builder: (BuildContext context) {        return AlertDialog(          title: const Text('Geoposition is off!'),          content: const Text(              'To use the app you have to enable bluetooth.'),          actions: [            ElevatedButton(              onPressed: () {                // Закрыть приложение                Navigator.of(context).pop();                Fluttertoast.showToast(                  msg: 'App is off',                  toastLength: Toast.LENGTH_SHORT,                  gravity: ToastGravity.BOTTOM,                );                Future.delayed(const Duration(seconds: 1), () => exit(0));              },              child: const Text('Close'),            ),            ElevatedButton(              onPressed: () {                // Открыть настройки устройства                Navigator.of(context).pop();                openLocationSettings();              },              child: const Text('Settings'),            ),          ],        );      },    );  }  Future<void> openLocationSettings() async {    AndroidIntent intent = const AndroidIntent(      action: 'android.settings.LOCATION_SOURCE_SETTINGS',    );    await intent.launch();  }  @override  Widget build(BuildContext context) {    checkLocationPermission(); // Проверяем разрешение на геопозицию при запуске приложения    return MaterialApp(      title: 'Grid Main Screen',      home: Scaffold(        backgroundColor: const Color.fromRGBO(0, 114, 143, 80),        body:        Padding(padding: const EdgeInsets.only(top: 23, left: 3, right: 3, bottom: 1),          child: Column(            children: [              //first row with logo and template for battery              Expanded(                flex: 12,                child: Row(                  mainAxisAlignment: MainAxisAlignment.spaceBetween,                    children: [                      const Padding(                        padding: EdgeInsets.all(5),                        child: Image(                          image: AssetImage('assets/logo1.png'), width: 50, height: 50,                        ),                      ),                      const Text(                        "SyDev1",                        style: TextStyle(                          color: Color.fromRGBO(230, 230, 230, 100),                          fontSize: 40                        ),                      ),                      IconButton(                        icon: const Icon(Icons.menu, size: 40, color: Color.fromRGBO(230, 230, 230, 100),),                        onPressed: () {                          Navigator.push(                            context,                            MaterialPageRoute(builder: (context) => const MenuScreen()),                          );                        },                      ),                ]),              ),              //second row with template for speedometer              Expanded(                flex: 35,                child: Row(                  children: <Widget>[                    // First column - 20%                    Expanded(                      flex: 2,                      child: Column(                        mainAxisAlignment: MainAxisAlignment.center,                        children: <Widget>[                          _createCell('Column 1'),                        ],                      ),                    ),                    // Second column - 40%                    Expanded(                      flex: 5,                      child: Column(                        mainAxisAlignment: MainAxisAlignment.center,                        children: <Widget>[                          _showSpeed(),                        ],                      ),                    ),                    // Third column - 40%                    Expanded(                      flex: 3,                      child: Column(                        mainAxisAlignment: MainAxisAlignment.center,                        children: <Widget>[                          const Expanded(                            child: Align(                              alignment: Alignment.bottomLeft,                              child: Padding(                                padding: const EdgeInsets.all(8.0),                                child: Text(                                  "km/h",                                  style: TextStyle(                                    fontSize: 30,                                    color: Color.fromRGBO(230, 230, 230, 100)                                  ),                                ),                              ),                            ),                          ),                          _showBattery('Item 6'),                        ],                      ),                    ),                  ],                )              ),              Expanded(                flex: 54,                  child: Padding(                    padding: const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 8),                    child: Column (                      children: [                        Expanded(                          flex: 2,                          child: Row(                            children: [                              //Voltage                              Expanded(                                child: Container(                                  width: 200,                                  height: 200,                                  margin: const EdgeInsets.all(5),                                  decoration: BoxDecoration(                                    color: const Color(0xFF2BB8C9),                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded                                  ),                                  child: Padding(                                    padding: const EdgeInsets.only(top: 5),                                    child: Column(                                      mainAxisAlignment: MainAxisAlignment.start,                                      children: [                                        const Text(                                          'VESC_ID',                                          style: TextStyle(                                            fontSize: 15,                                            color: Colors.white30,                                          ),                                        ),                                        const SizedBox(height: 20),  // Add some space between the two pieces of text                                        Text(                                          '${Singleton.telemetryPacket.vesc_id} V',                                          style: const TextStyle(                                            fontSize: 35,                                            color: Colors.white,                                          ),                                        ),                                      ],                                    ),                                  ),                                ),                              ),                              //Current                              Expanded(                                child: Container(                                  width: 200,                                  height: 200,                                  margin: const EdgeInsets.all(5),                                  decoration: BoxDecoration(                                    color: const Color(0xFF2BB8C9),                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded                                  ),                                  child: Padding(                                    padding: const EdgeInsets.only(top: 5),                                    child: Column(                                      mainAxisAlignment: MainAxisAlignment.start,                                      children: [                                        const Text(                                          'CURRENT',                                          style: TextStyle(                                            fontSize: 15,                                            color: Colors.white30,                                          ),                                        ),                                        const SizedBox(height: 20),  // Add some space between the two pieces of text                                        Text(                                          '${Singleton.telemetryPacket.current_in} A',                                          style: const TextStyle(                                            fontSize: 35,                                            color: Colors.white,                                          ),                                        ),                                      ],                                    ),                                  ),                                ),                              ),                            ],                          ),                        ),                        Expanded(                          flex: 2,                          child: Row(                            children: [                              //Temperature                              Expanded(                                child: Container(                                  width: 200,                                  height: 200,                                  margin: const EdgeInsets.all(5),                                  decoration: BoxDecoration(                                    color: const Color(0xFF2BB8C9),                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded                                  ),                                  child: Padding(                                    padding: const EdgeInsets.only(top: 5),                                    child: Column(                                      mainAxisAlignment: MainAxisAlignment.start,                                      children: [                                        const Text(                                          'TEMPERATURE',                                          style: TextStyle(                                            fontSize: 15,                                            color: Colors.white30,                                          ),                                        ),                                        const SizedBox(height: 20),  // Add some space between the two pieces of text                                        Text(                                          '${Singleton.telemetryPacket.temp_mos}°C',                                          style: const TextStyle(                                            fontSize: 35,                                            color: Colors.white,                                          ),                                        ),                                      ],                                    ),                                  ),                                ),                              ),                              //mode                              Expanded(                                child: Container(                                  width: 200,                                  height: 200,                                  margin: const EdgeInsets.all(5),                                  decoration: BoxDecoration(                                    color: const Color(0xFF2BB8C9),                                    borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded                                  ),                                  child: Padding(                                    padding: const EdgeInsets.only(top: 5),                                    child: Column(                                      mainAxisAlignment: MainAxisAlignment.start,                                      children: [                                        const Text(                                          'VOLTAGE',                                          style: TextStyle(                                            fontSize: 15,                                            color: Colors.white30,                                          ),                                        ),                                        const SizedBox(height: 20),  // Add some space between the two pieces of text                                        Text(                                          '${Singleton.telemetryPacket.v_in} V',                                          style: const TextStyle(                                            fontSize: 35,                                            color: Colors.white,                                          ),                                        ),                                      ],                                    ),                                  )                                ),                              ),                            ],                          ),                        ),                        //fifth row with status                        Expanded(                          child: Container(                              margin: const EdgeInsets.all(5),                              decoration: BoxDecoration(                                color: const Color(0xFF2BB8C9),                                borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded                              ),                              child: Center(                                  child: Text(                                    'Status: ${Singleton.telemetryPacket.fault_code.name}',                                    style: const TextStyle(                                      fontSize: 20,                                      color: Colors.white70,                                    ),                                  )                              )                          ),                        ),                      ],                    ),                  )              )            ],          ),        ),      ),    );  }  Widget _createCell(String text) {    return Expanded(      child: Container(        alignment: Alignment.center,        margin: const EdgeInsets.all(2), // Add some space between cells        decoration: BoxDecoration(          border: Border.all(color: Colors.black), // Create border        ),        child: Text(text),      ),    );  }  // Widget _cellForData(int i){  //  //   String textForCell;  //  //   switch (i){  //     case 0:  //       textForCell = '$voltage V';  //       break;  //     case DATA_ID.CURRENT:  //       textForCell = '$current A';  //       break;  //     case DATA_ID.TEMPERATURE:  //       textForCell = '$temperature°C';  //       break;  //     case DATA_ID.MODE:  //       textForCell = 'SPORT';  //       break;  //     default:  //       textForCell = "zjf";  //       break;  //   }  //  //   return Expanded(  //     child:  //     Container(  //       width: 200,  //       height: 200,  //       margin: const EdgeInsets.all(5),  //       decoration: BoxDecoration(  //         color: const Color(0xFF2BB8C9),  //         borderRadius: BorderRadius.circular(5), // Set the border radius to make corners rounded  //       ),  //       child: Column(  //         mainAxisAlignment: MainAxisAlignment.center,  //         children: [  //           Text(  //             'VOLTAGE',  //             style: const TextStyle(  //               fontSize: 15,  //               color: Colors.white30,  //             ),  //           ),  //           SizedBox(height: 20),  // Add some space between the two pieces of text  //           Text(  //             '$textForCell',  //             style: const TextStyle(  //               fontSize: 35,  //               color: Colors.white,  //             ),  //           ),  //         ],  //       ),  //     ),  //   );  // }  void sendPacket(int command) async {    Uint8List packet = simpleVESCRequest(command);;    // Request COMM_GET_VALUES_SETUP from the ESC    if (!await sendBLEData(Singleton.tx, packet, true)) {      globalLogger.e("_requestTelemetry() failed");    } else {      print("Hello this is sendBLEData");    }    print("after rx tx");  }  _showSpeed() {    return const Center(          child: Text(            '27',            style: TextStyle(                color: Color.fromRGBO(230, 230, 230, 100),                fontSize: 140,                fontWeight: FontWeight.w500            ),          ),        );  }  _showBattery(String s) {    return Center(      child: Stack(        alignment: Alignment.center,        children: [          // Battery icon (background)          Transform.rotate(            angle: pi / 2,            child: const Icon(              Icons.battery_full,              size: 100,              color: Color.fromRGBO(230, 230, 230, 100),            ),          ),          // Battery level text (foreground)          Text(            '$batteryLevel %',            textAlign: TextAlign.center,            style: const TextStyle(              color: Color.fromRGBO(0, 79, 99, 100),              fontWeight: FontWeight.bold,              fontSize: 55 * 0.4,            ),          ),        ],      ),    );  }}