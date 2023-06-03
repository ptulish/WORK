import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    super.initState();
    findDevices();

  }

  void startScan(){

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color.fromRGBO(0, 114, 143, 80),
      body: Container(
        padding: const EdgeInsets.fromLTRB(5, 30, 5, 10),
        child: Column(
          children: [
            //logo as top-bar
            Expanded(
              flex: 15,
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
            //Devices heading
            Expanded(
              flex: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      'Devices',
                      style: TextStyle(
                        fontSize: 40,
                        color: Color.fromRGBO(230, 230, 230, 100),
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        startScan();
                      },
                      style:  ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // установите значение радиуса по своему усмотрению
                        ),
                      ),
                      child: const Text(
                        'Scan',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ]
              ),
            ),
            // Line under dem ersten Raster-Row
            Container(
              margin: const EdgeInsets.only(left: 15, right: 30),
              height: 3,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(230, 230, 230, 100),
                borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
              ),
            ),
            Expanded(
              flex: 75,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 0),
                itemCount: 10, // Anzahl der Elemente in der Liste
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item $index'),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/');
                                    //connectDevice("device.name");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // установите значение радиуса по своему усмотрению
                                    ),
                                  ),
                                  child: const Text('Connect'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  late ScanResult result;

  void findDevices () async {
    bool isConnected = false;
    bool isBluetoothEnabled = await flutterBlue.isOn;
    bool isBluetoothAvailable = await flutterBlue.isAvailable;
    BluetoothDevice device;
    List<BluetoothService> services;

    if (!isBluetoothAvailable) {
      if (kDebugMode) {
        print('bluetooth is unaviable');
      }
      return;
    }
    if (!isBluetoothEnabled) {
      // Bluetooth ist deaktiviert, fordern Sie den Benutzer auf, es einzuschalten
      // oder schalten Sie es programmgesteuert ein (falls unterstützt)
      if (kDebugMode) {
        print("bluetooth is aus");
      }
      return;
    }

    if (kDebugMode) {
      print("$isBluetoothAvailable $isBluetoothEnabled");
    }
    // Start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    var scanSubscription = flutterBlue.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (kDebugMode) {
          print(result.device.name);
        }

        if (result.device.name == 'SY2 BLE' && !isConnected) {
          listOfDevices.add(result.device.name);
          device = result.device;

          await device.connect();
          isConnected = true;

          services = await device.discoverServices();

          for (BluetoothService service in services) {
            if (kDebugMode) {
              print('Service: ${service.characteristics}');
            }
          }
        }
      }


      flutterBlue.stopScan();
      return;
    });
    if(kDebugMode){
      print(scanSubscription);
    }
    // Nach dem Scannen eine bestimmte Zeit warten und dann den Scan beenden
  }

  void connectDevice() {}
}
