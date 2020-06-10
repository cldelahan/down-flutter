import 'package:flutter/material.dart';
import "Pages/LoginScreen.dart";
import 'package:down/Pages/HomePage.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

//void main() => runApp(MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;

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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // put theme data and colors here
          //primarySwatch: Colors.blue,
          primaryColor: Color(0xff26c586),
          secondaryHeaderColor: Color(0xff26c586),
          accentColor: Color(0xff17a68b)),
      // app initially starts off at Login Screen
      // if there is no need to Login, will go directly to home page
      home: LoginScreen(),
    );
  }
}

/*
Future<Widget> getLandingPage() async {
  return StreamBuilder<FirebaseUser> (
    stream: _auth.onAuthStateChanged,
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData && (!snapshot.data.isAnonymous)) {
        return HomePage();
      }
      return LoginScreen();
    }
  );
}*/
