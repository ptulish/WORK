import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:workproject/pages/main_screen.dart';
import 'package:workproject/classes/ConnectedDevice.dart';

import '../bleHelper.dart';
import '../dataTypes.dart';
import '../globalUtilities.dart';
import '../classes/singleton.dart';


class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<String> listOfDevices = [];// = newObject();
  BluetoothDevice? device;
  bool isConnected = false;

  String? deviceAddress;
  late BluetoothService targetService;
  BLEHelper bleHelper = BLEHelper();
  int index = 0;
  int payloadLength = 0;
  int packetLength = 0;
  List<int> list = [];
  int ind = 0;


  @override
  void initState() {
    if(isConnected == true){
      device?.disconnect();
    }
    super.initState();
    bluetoothCheck();
  }

  Future<String> _loadData() async {
    findDevices();
    await Future.delayed(const Duration(seconds: 2)); // Имитация долгой загрузки данных
    return 'OK'; // Здесь должны быть ваши загруженные данные
  }

  Widget loadingScreen(int i){
    if(i <= 1){
      return const Scaffold(
        backgroundColor: Color.fromRGBO(0, 114, 143, 80),
        body: Center(
            child: Text(
              'Welcome to Sylents',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 35,
                color: Colors.white54,
              ),
            )
        ),
      );// показывает индикатор загрузки
    } else {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(0, 114, 143, 80),
        body: Center(
            child: Text(
              'Loading...',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 35,
                color: Colors.white54,
              ),
            )
        ),
      );// показывает индикатор загрузки
    }
  }


  Widget headindPlusButton() {
    return Expanded(
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
                  setState(() {
                    if(isConnected == true){
                      device?.disconnect();
                    }
                    findDevices();

                  });
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
    );
  }

  Widget devicesList() {
    return Expanded(
      flex: 75,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        itemCount: listOfDevices.length, // Anzahl der Elemente in der Liste
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(listOfDevices.elementAt(index)),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () async {

                              Navigator.of(context).push(LoadingOverlay()); // Отображаем индикатор загрузки

                              await connectDevice(listOfDevices.elementAt(index));
                              getServicesAndFirmware();
                              Future.delayed(const Duration(seconds: 2), () {
                                // Здесь может быть ваш код, который будет выполнен после задержки.
                                Navigator.of(context).pop(); // Убираем индикатор загрузки
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Connect to ${device?.name}'),
                                      content: Text('FIRMWARE:\n'
                                          'Major: ${Singleton.firmware?.fw_version_major}\n'
                                          'Minor: ${Singleton.firmware?.fw_version_minor}\n'
                                          'Firmware: ${Singleton.firmware?.hardware_name}\n'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('ОК'),
                                          onPressed: () {
                                            // Здесь ваша функция перехода на новый экран
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => MainScreen(device: device)),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // установите значение радиуса по своему усмотрению
                              ),
                            ),
                            child: const Text('Connect'),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadData(), // функция, которую нужно выполнить
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && ind == 0) {
          ind++;
          return loadingScreen(ind);
        } else if (snapshot.connectionState == ConnectionState.waiting && ind > 0) {
          ind++;
          return loadingScreen(ind);
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Это ваш Scaffold, который заменяет "Data: ${snapshot.data}"
            return Scaffold(
              backgroundColor: const Color.fromRGBO(0, 114, 143, 80),
              body: Container(
                padding: const EdgeInsets.fromLTRB(5, 30, 5, 10),
                child: Column(
                  children: [
                    //logo as top-bar
                    logo(),
                    //Devices heading
                    headindPlusButton(),
                    // Line under dem ersten Raster-Row
                    Container(
                      margin: const EdgeInsets.only(left: 15, right: 30),
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(230, 230, 230, 100),
                        borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                      ),
                    ),
                    devicesList(),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }


  Widget showDialog1(){
    return AlertDialog(
      title: const Text('Bluetooth'),
      content: const Text('There is some problem with Bluetooth.'),
      actions: <Widget>[
        TextButton(
          child: const Text('ОК'),
          onPressed: () {
            Navigator.of(context).pop(); // Эта строка закрывает всплывающее окно
          },
        ),
      ],
    );
  }

  late ScanResult result;

  void findDevices() async {
    // Используйте Set для автоматической фильтрации дубликатов
    Set<String> deviceSet = {};
    if(isConnected == true){
      device?.disconnect();
    }

    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    var scanSubscription = flutterBlue.scanResults.listen((results) async {
      for (ScanResult result in results) {
        String deviceName = result.device.name;
        // print(result.device.name);

        if (deviceName.startsWith("SY2")) {
          // Просто добавьте имя устройства в Set
          deviceSet.add(deviceName);
        }
      }
      listOfDevices = deviceSet.toList();
    });

    if (kDebugMode) {
      print(scanSubscription);
    }
  }

  Future<void> connectDevice(String deviceNameToConnect) async {
    // Start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 1));

    BluetoothDevice? targetDevice;

    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == deviceNameToConnect) {
          targetDevice = result.device;
          device = result.device;  // обновите device тут
          ConnectedDevice.instance.device = targetDevice;
          break;
        }
      }
    });
    if(kDebugMode){
      print(subscription);
    }

    // Delay stopping scan to ensure scan has had time to complete
    await Future.delayed(const Duration(seconds: 1)).then((_) => flutterBlue.stopScan());

    if (targetDevice != null) {
      // Connect to the device
      if (await targetDevice?.state == BluetoothDeviceState.connected) {
        if (kDebugMode) {
          print('Device is already connected');
        }
      } else {
        // Connect to the device
        await targetDevice?.connect();
        if (kDebugMode) {
          print('Connected to ${targetDevice?.name}');
        }
      }
    } else {
      if (kDebugMode) {
        print('Target Device Not Found');
      }
    }
  }

  void bluetoothCheck() async {
    bool isBluetoothEnabled = await flutterBlue.isOn;
    bool isBluetoothAvailable = await flutterBlue.isAvailable;

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
  }

  void getServicesAndFirmware() async {
    List<BluetoothService>? services = await device?.discoverServices();

    // Обнаружение служб
    Singleton.uartService = services!.firstWhere(
          (service) => service.uuid == Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
    );

    // Находим характеристики для RX и TX
    //transmit
    Singleton.tx = Singleton.uartService?.characteristics.firstWhere(
          (c) => c.uuid == Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e"),
    );
    // receive
    Singleton.rx = Singleton.uartService?.characteristics.firstWhere(
          (c) => c.uuid == Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e"),
    );
    try {
      if(Singleton.rx?.properties.notify == true){
        // await Future.delayed(Duration(seconds: 2));
        await Singleton.rx?.setNotifyValue(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to setup notifications: $e");
      }
    }
    listen();
    sendPacket(COMM_PACKET_ID.COMM_FW_VERSION.index);
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Предотвратить закрытие диалога нажатием вне его
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Color.fromARGB(230, 230, 230, 100),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              // new Text("Loading"),
            ],
          ),
        );
      },
    );
  }



}

class LoadingOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}