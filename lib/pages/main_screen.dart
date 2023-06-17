import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'dart:async';
import 'package:workproject/classes/ConnectedDevice.dart';

import 'package:workproject/pages/scan.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return const MaterialApp(
//       title: 'Main Screen',
//       home: MainScreen(),
//     );
//   }
//
// }

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

  @override
  void initState() {
    super.initState();
    checkLocationService();
    checkLocationPermission();
  }

  Future<void> checkLocationService() async {
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    // print(isLocationPermissionGranted);
    // print(isLocationServiceEnabled);

    if (isLocationServiceEnabled && isLocationPermissionGranted) {
      // Геопозиция включена, продолжаем с приложением
      // Вместо простого вывода на консоль, вы можете перейти к основному экрану вашего приложения
      getPosition();
    } else {
      // Геопозиция отключена, показываем всплывающее окно
      showLocationServiceDisabledDialog();
    }

    BluetoothDevice? device = ConnectedDevice.instance.device;

    print(device?.name);


  }

  void showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Геопозиция отключена'),
          content: const Text(
              'Для использования приложения необходимо включить геопозицию.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Закрыть приложение
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Приложение закрыто',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                Future.delayed(const Duration(seconds: 1), () => exit(0));
              },
              child: const Text('Закрыть'),
            ),
            ElevatedButton(
              onPressed: () {
                // Открыть настройки устройства
                Navigator.of(context).pop();
                openLocationSettings();
              },
              child: const Text('Настройки'),
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
                    ' ',
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

  Future<void> checkLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.status;
    setState(() {
      isLocationPermissionGranted =
          permissionStatus == PermissionStatus.granted;
    });
    //print("device: ${device?.name}");
  }

  void getPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      if (kDebugMode) {
        print('Latitude: $latitude');
        print('Longitude: $longitude');
      }
    } catch (e) {
      // Обработка ошибок
      if(kDebugMode) {
        print('Error: $e');
      }
    }
  }
}

