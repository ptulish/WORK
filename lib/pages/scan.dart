import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<String> listOfDevices = [];// = newObject();


  @override
  void initState(){
    // findDevices();

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color.fromRGBO(0, 114, 143, 80),
      // appBar: AppBar(
      //   title: Text('Grid Example'),
      // ),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 30, 5, 10),
        child: Column(
          children: [
            //logo as topbar
            Expanded(
              flex: 15,
              child: Container(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.19, // Adjust this value as needed
                    heightFactor: 0.5, // Adjust this value as needed
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/logo.png',
                      ),
                    ),
                  ),
                ),
              ),
              // child: SizedBox(
              //   width: 40,
              //   height: 20,
              //   child: Container(
              //     child: Align(
              //       alignment: Alignment.topLeft,
              //       child: FittedBox(
              //         fit: BoxFit.contain,
              //         child: Image.asset(
              //           'assets/logo.png',
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ),
            //Devices heading
            const Expanded(
              flex: 10,
              child: Center(
                child: Text(
                  'Devices',
                  style: TextStyle(
                      fontSize: 40,
                      color: Color.fromRGBO(230, 230, 230, 100),
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
            // Linie unter dem ersten Raster-Row
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: Color.fromRGBO(230, 230, 230, 100),
                borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
              ),
            ),
            Expanded(
              flex: 75,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 0),
                itemCount: 10, // Anzahl der Elemente in der Liste
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Item $index'),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/');
                                    //connectDevice("device.name");
                                  },
                                  child: Text('Connect'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

//late ScanResult result;
//
// void findDevices () async {
//   bool isConnected = false;
//   bool isBluetoothEnabled = await flutterBlue.isOn;
//   bool isBluetoothAvailable = await flutterBlue.isAvailable;
//   BluetoothDevice device;
//   List<BluetoothService> services;
//
//   if (!isBluetoothAvailable) {
//     print('bluetooth is unaviable');
//     return;
//   }
//   if (!isBluetoothEnabled) {
//     // Bluetooth ist deaktiviert, fordern Sie den Benutzer auf, es einzuschalten
//     // oder schalten Sie es programmgesteuert ein (falls unterstützt)
//     print("bluetooth is aus");
//     return;
//   }
//
//   // Start scanning
//   flutterBlue.startScan();
//
//   var scanSubscription = flutterBlue.scanResults.listen((results) async {
//     for (ScanResult result in results) {
//
//       if (result.device.name == 'SY2 BLE' && !isConnected) {
//
//         listOfDevices.add(result.device.name);
//         device = result.device;
//
//         await device.connect();
//         isConnected = true;
//
//         services = await device.discoverServices();
//
//         for (BluetoothService service in services) {
//           print('Service: ${service.characteristics}');
//         }
//
//
//         flutterBlue.stopScan();
//         return;
//       }
//     }
//   });
//
//
//   // Nach dem Scannen eine bestimmte Zeit warten und dann den Scan beenden
//
// }
//
// void connectDevice() {}
}
