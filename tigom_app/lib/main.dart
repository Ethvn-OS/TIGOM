import 'package:flutter/material.dart';

void main() {

  runApp( MyApp() );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('TIGOM'),
          centerTitle: true,
        ),

        body: Container(
          alignment: Alignment.center,
          child: const Text('Hi mom'),
          margin: const EdgeInsets.all(50),
          padding: const EdgeInsets.all(10),
          color: Colors.red,
          height: 100,
          width: 100,
        ),

        bottomNavigationBar: BottomNavigationBar(items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
          )
        ]),
      ),
    );
  }
}