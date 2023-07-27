import 'package:flutter/material.dart';

import '../classes/singleton.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 114, 143, 80),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image(
                      image: AssetImage('assets/images/logo1.png'), width: 50, height: 50,
                    ),
                    Text(
                      "SyDev1",
                      style: TextStyle(
                          color: Color.fromRGBO(230, 230, 230, 100),
                          fontSize: 40
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 50),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: TextButton(
                        onPressed: (){
                          //TODO DISCONNECT LOGIK
                        },
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(
                            fontSize: 30,
                            color: Color.fromRGBO(230, 230, 230, 100),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: TextButton(
                        onPressed: (){
                          _showBottomSheet(context);
                        },
                        child: const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 30,
                            color: Color.fromRGBO(230, 230, 230, 100),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(items[index].title),
                          DropdownButton<String>(
                            items: items[index].options.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              // Here your function, which runs when selecting an option
                              switch (index){
                                case 0:
                                  Singleton.topLeft = newValue!;
                                  break;
                                case 1:
                                  Singleton.topRight = newValue!;
                                  break;
                                case 2:
                                  Singleton.bottomLeft = newValue!;
                                  break;
                                case 3:
                                  Singleton.bottomRight = newValue!;
                                  break;
                                default:
                                  break;
                              }
                              setState(() {
                                items[index].selectedValue = newValue!;  // Set the selected value
                              });
                            },
                            hint: Text(items[index].selectedValue), // Use the hint from your MenuItem object
                          ),
                        ],
                      ),
                    );
                  }
              );
            },
          );
        }
    );
  }
}

class ListItem {
  final String title;
  final List<String> options;
  String selectedValue;

  ListItem(this.title, this.options, this.selectedValue);
}

// Список элементов
final items = <ListItem>[
  ListItem('Top left', ['Power', 'MOSFET Temperature', 'Motor Temperature', 'Motor Current','Input Current','Field Oriented Control Id (DAC)','Field Oriented Control Iq (QAD)','Current Duty Cycle','Revolutions Per Minute','Input Voltage','Ampere Hours','Ampere Hours Charged','Watt Hours','Watt Hours Charged','Tachometer Reading', 'Absolute Tachometer Reading', 'Position', 'Direct Axis Voltage', 'Quadrature Axis Voltage'], Singleton.topLeft),
  ListItem('Top right', ['Power', 'MOSFET Temperature', 'Motor Temperature', 'Motor Current','Input Current','Field Oriented Control Id (DAC)','Field Oriented Control Iq (QAD)','Current Duty Cycle','Revolutions Per Minute','Input Voltage','Ampere Hours','Ampere Hours Charged','Watt Hours','Watt Hours Charged','Tachometer Reading', 'Absolute Tachometer Reading', 'Position', 'Direct Axis Voltage', 'Quadrature Axis Voltage'], Singleton.topRight),
  ListItem('Bottom left', ['Power', 'MOSFET Temperature', 'Motor Temperature', 'Motor Current','Input Current','Field Oriented Control Id (DAC)','Field Oriented Control Iq (QAD)','Current Duty Cycle','Revolutions Per Minute','Input Voltage','Ampere Hours','Ampere Hours Charged','Watt Hours','Watt Hours Charged','Tachometer Reading', 'Absolute Tachometer Reading', 'Position', 'Direct Axis Voltage', 'Quadrature Axis Voltage'], Singleton.bottomLeft),
  ListItem('Bottom right', ['Power', 'MOSFET Temperature', 'Motor Temperature', 'Motor Current','Input Current','Field Oriented Control Id (DAC)','Field Oriented Control Iq (QAD)','Current Duty Cycle','Revolutions Per Minute','Input Voltage','Ampere Hours','Ampere Hours Charged','Watt Hours','Watt Hours Charged','Tachometer Reading', 'Absolute Tachometer Reading', 'Position', 'Direct Axis Voltage', 'Quadrature Axis Voltage'], Singleton.bottomRight),
];
