// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    checkLocationService();
  }

  Future<void> checkLocationService() async {
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled) {
      // Геопозиция включена, продолжаем с приложением
      // Вместо простого вывода на консоль, вы можете перейти к основному экрану вашего приложения
      print('Location services are enabled.');
      showLocationServiceDisabledDialog();

    } else {
      // Геопозиция отключена, показываем всплывающее окно
      showLocationServiceDisabledDialog();
      print("they're off");
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
    return Scaffold(
      appBar: AppBar(
        title: Text('GeoPosition Demo'),
      ),
      body: Center(
        child: Text('Главный экран'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          checkLocationService();
        },
        child: Text("нажми"),
      ),
    );
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
