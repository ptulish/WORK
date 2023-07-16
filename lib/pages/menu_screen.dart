import 'package:flutter/material.dart';

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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}