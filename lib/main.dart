import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';


void main() {
  runApp(MyApp());
}

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
  String regime = "Sport";
  String status = "Everything is okay";


  @override
  void initState() {
    super.initState();
    checkLocationService();
    checkLocationPermission();

  }

  Future<void> checkLocationService() async {
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    print(isLocationPermissionGranted);
    print(isLocationServiceEnabled);

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
          content: Text('Для использования приложения необходимо включить геопозицию.'),
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
                            width: 100,  // Укажите требуемую ширину
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
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.black,
                  //     width: 1.0,
                  //   ),
                  // ),
                  child: Center(
                    child: Text(
                        '10 km/h',
                      style: TextStyle(
                        color: Color.fromRGBO(230, 230, 230, 100),
                        fontSize: 100,
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
                    Expanded(
                      child:
                      Container(
                        width: 200,
                        height: 200,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
                        ),
                        //Voltage
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
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
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
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
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
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2BB8C9),
                          borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
                        ),
                        child: Center(
                          child: Text(
                            '$regime',
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Colors.black,
                      //       width: 1.0,
                      //     ),
                      //   ),
                      //   child: Center(
                      //     child: Text('Fourth Row - Column 2'),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
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
                      ),
                    )
                  )
                ),
                // child: Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         width: 200,
                //         height: 100,
                //         margin: EdgeInsets.all(5),
                //         decoration: BoxDecoration(
                //           color: Color(0xFF2BB8C9),
                //           borderRadius: BorderRadius.circular(10), // Set the border radius to make corners rounded
                //         ),
                //         child: Center(
                //           child: Expanded(
                //             child: Text(
                //               'Status: $status',
                //               style: TextStyle(
                //                 fontSize: 20,
                //
                //               ),
                //             ),
                //           ),
                //
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
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
      isLocationPermissionGranted = permissionStatus == PermissionStatus.granted;
    });
  }
  void getPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      print('Latitude: $latitude');
      print('Longitude: $longitude');
    } catch (e) {
      // Обработка ошибок
      print('Error: $e');
    }
  }
}










//
// class MyApp extends StatelessWidget {
//   MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   Future<bool> checkLocationService() async {
//     bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
//     return await Geolocator.isLocationServiceEnabled() ? true : false;
//     if (isLocationServiceEnabled) {
//       print('Location services are enabled.');
//     } else {
//       print('Location services are disabled.');
//     }
//   }
//
//   Geolocator geolocator = Geolocator();
//   LocationOptions locationOptions =
//   LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
//
//   StreamSubscription<Position> positionStream = Geolocator.getPositionStream()
//       .listen((Position position) {
//        double speed = position.speed;
//
//     // Обработка изменений позиции
//   });
//
//   void getPosition() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       double latitude = position.latitude;
//       double longitude = position.longitude;
//       print('Latitude: $latitude');
//       print('Longitude: $longitude');
//       // Используйте полученные координаты (latitude и longitude) для дальнейшей обработки
//     } catch (e) {
//       // Обработка ошибок
//     }
//   }
//
//
//   void _incrementCounter() {
//     setState(() {
//       print(geolocator.toString());
//       print(locationOptions);
//       print(positionStream);
//       getPosition();
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
