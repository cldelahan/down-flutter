import 'package:flutter/material.dart';
import 'package:down/Pages/HomePage.dart';

//void main() => runApp(MyApp());

const color1 = const Color(0xff26c586);
const transColor = Color(0x00000000);


void main() {
  /*
  runApp(new MaterialApp(
      home: new MyTabs()
  ));*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // put theme data and colors here
        primarySwatch: Colors.blue,
        primaryColor: Color(0xff26c586),
        accentColor: Color(0xff17a68b)
      ),
      home: HomePage(),
    );
  }
}