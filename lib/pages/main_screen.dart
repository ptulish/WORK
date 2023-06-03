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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'GeoPosition Demo',
      home: GeoPositionCheckScreen(),
    );
  }

}

class GeoPositionCheckScreen extends StatefulWidget {
  @override
  _GeoPositionCheckScreenState createState() => _GeoPositionCheckScreenState();
}

class _GeoPositionCheckScreenState extends State<GeoPositionCheckScreen> {
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
  }

  void showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Геопозиция отключена'),
          content: Text(
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
                Future.delayed(Duration(seconds: 1), () => exit(0));
              },
              child: Text('Закрыть'),
            ),
            ElevatedButton(
              onPressed: () {
                // Открыть настройки устройства
                Navigator.of(context).pop();
                openLocationSettings();
              },
              child: Text('Настройки'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openLocationSettings() async {
    AndroidIntent intent = AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    checkLocationPermission(); // Проверяем разрешение на геопозицию при запуске приложения

    return MaterialApp(
      title: 'Grid Example',
      home: Scaffold(
        backgroundColor: Color.fromRGBO(0, 114, 143, 80),
        // appBar: AppBar(
        //   title: Text('Grid Example'),
        // ),
        body:
        Padding(padding: EdgeInsets.only(top: 23, left: 3, right: 3, bottom: 1),
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
                        Padding(padding: EdgeInsets.all(5),
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
                      child: Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     color: Colors.black,
                        //     width: 1.0,
                        //   ),
                        // ),
                        child: Center(
                          child: Stack(
                            children: [
                              Center(
                                child:
                                Transform.rotate(angle: pi / 2, child: Icon(
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
                                  style: TextStyle(
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
                    ),
                  ],
                ),
              ),
              //second row fith template for speedometer
              Expanded(
                flex: 3,
                child: Container(
                  child: Center(
                    child: Text(
                      '10 km/h',
                      style: TextStyle(
                          color: Color.fromRGBO(230, 230, 230, 100),
                          fontSize: 90,
                          fontWeight: FontWeight.w500
                      ),
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
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$voltage V',
                            style: TextStyle(
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
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$current A',
                            style: TextStyle(
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
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$temperature° С',
                            style: TextStyle(
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
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(
                              10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$mode',
                            style: TextStyle(
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
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFF2BB8C9),
                      borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
                    ),
                    child: Center(
                        child: Text(
                          'Status: $status',
                          style: TextStyle(
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
  }

  void getPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // print('Latitude: $latitude');
      // print('Longitude: $longitude');
    } catch (e) {
      // Обработка ошибок
      print('Error: $e');
    }
  }


}

