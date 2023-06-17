


import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectedDevice {
  BluetoothDevice? device;

  // Private constructor
  ConnectedDevice._privateConstructor();

  // Singleton instance
  static final ConnectedDevice instance = ConnectedDevice._privateConstructor();

}
