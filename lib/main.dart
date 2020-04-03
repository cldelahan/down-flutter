import 'package:flutter/material.dart';
import './HomePage.dart';
import './FeedPage.dart' as first;
import './DownPage1.dart' as second;
import './BurgerPage.dart' as third;

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
      ),
      home: HomePage(),
    );
  }
}