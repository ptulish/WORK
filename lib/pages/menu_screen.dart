import 'package:flutter/material.dart';

import '../classes/singleton.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

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

  // void _showBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return ListView.builder(
  //           itemCount: 4,
  //           itemBuilder: (context, index) {
  //             return DropdownButton<String>(
  //               items: <String>["Power", "Current"]
  //                   .map<DropdownMenuItem<String>>((String value) {
  //                 return DropdownMenuItem<String>(
  //                   value: value,
  //                   child: Text(value),
  //                 );
  //               }).toList(),
  //               onChanged: (String? newValue) {
  //                 // Здесь ваша функция, которая выполняется при выборе опции
  //                 print('User selected $newValue');
  //               },
  //               hint: Text('руддщ'),
  //             );
  //           },
  //         );
  //       });
  // }
  // void _showBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return ListView.builder(
  //           itemCount: items.length,
  //           itemBuilder: (context, index) {
  //             return
  //               Expanded(
  //                 child: Column(
  //                 children: [
  //                   Text(items[index].title), // Вывод названия элемента
  //                   DropdownButton<String>(
  //                     items: items[index].options.map<DropdownMenuItem<String>>((String value) {
  //                       return DropdownMenuItem<String>(
  //                         value: value,
  //                         child: Text(value),
  //                       );
  //                     }).toList(),
  //                     onChanged: (String? newValue) {
  //                       // Здесь ваша функция, которая выполняется при выборе опции
  //
  //
  //                       switch (index){
  //                         case 0:
  //                           Singleton.topLeft = newValue!;
  //                           break;
  //                         case 1:
  //                           Singleton.topRight = newValue!;
  //                           break;
  //                         case 2:
  //                           Singleton.bottomLeft = newValue!;
  //                           break;
  //                         case 3:
  //                           Singleton.bottomRight = newValue!;
  //                           break;
  //                         default:
  //                           break;
  //                       }
  //                       print('User selected $newValue, $index');
  //                     },
  //                     hint: Text('Выберите опцию'),
  //                   ),
  //                 ],
  //               ),
  //               );
  //           },
  //         );
  //       }
  //   );
  // }
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(8.0),  // Добавьте нужные вам отступы
                child: Column(
                  children: [

                    Text(items[index].title), // Вывод названия элемента
                    DropdownButton<String>(
                      items: items[index].options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Здесь ваша функция, которая выполняется при выборе опции
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
                        print('User selected $newValue, $index');
                      },
                      hint: Text('Выберите опцию'),
                    ),
                  ],
                ),
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

  ListItem(this.title, this.options);
}

// Список элементов
final items = <ListItem>[
  ListItem('Top left', ['MOSFET Temperature', 'Motor Temperature', 'Motor Current','Input Current','Field Oriented Control Id (Direct Axis Current)','Field Oriented Control Iq (Quadrature Axis Current)','Current Duty Cycle','Revolutions Per Minute','Input Voltage','Ampere Hours','Ampere Hours Charged','Watt Hours','Watt Hours Charged','Tachometer Reading']),
  ListItem('Top right', ['Option 2.1', 'Option 2.2', 'Option 2.3']),
  ListItem('Bottom left', ['Option 2.1', 'Option 2.2', 'Option 2.3']),
  ListItem('Bottom right', ['Option 2.1', 'Option 2.2', 'Option 2.3']),


  // Добавьте столько элементов, сколько вам нужно
];
