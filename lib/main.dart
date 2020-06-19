import 'package:flutter/material.dart';
import "Pages/LoginScreen.dart";
import 'package:down/Pages/HomePage.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

//void main() => runApp(MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Down',
      theme: ThemeData(
        primaryColor: Color(0xff10c260),
        buttonColor: Color(0xff3a82b8),
        backgroundColor: Color(0xfff0ecf1),
        accentColor: Color(0x22546a65),
        dialogBackgroundColor: Color(0xfff0ecf1),
        // color for businesses
        cardColor: Color(0xff74ccf2)

      ),
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
