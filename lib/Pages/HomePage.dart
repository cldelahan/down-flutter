import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Pages/CreateAccountPage.dart';
import '../Models/User.dart';
import 'package:down/Pages/FeedPage.dart' as FeedPage;
import 'package:down/Pages/CreateDown.dart' as CreateDown;
import 'package:down/Pages/BurgerPage.dart' as third;
import './UploadPage.dart';
import './SearchPage.dart';
import '../Widgets/MyApp.dart';


const color1 = const Color(0xff26c586);
const transColor = Color(0x00000000);
final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = FirebaseDatabase.instance.reference().child("Users");
User currentUser;

final DateTime timestamp = DateTime.now();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // signin variables
  bool isSignedIn = true;
  String phoneNumber;
  String password;

  // homepage variables
  PageController pageController;
  int getPageIndex = 0;


  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void loginUser() {
  }

  Widget showPhonenumberInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
    );
  }


  Widget buildHomeScreen() {
    //return RaisedButton.icon(onPressed: null, icon: Icon(Icons.close), label: Text("Sign Out"));
    return new MyTabs();
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container (
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor],
          )
        ),
        alignment: Alignment.center,
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Text ("Down",
            style: TextStyle(fontSize: 92.0, color: Colors.white, fontFamily: "Signatra"),
            ),
            GestureDetector(
              onTap: ()=> loginUser(),
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                  )
                )
              )
            )
          ],
        )
      ));
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}


class MyTabs extends StatefulWidget {
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin {

  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        bottomNavigationBar: new Material(
            color: transColor,
            child: new TabBar(
                controller: controller,
                tabs: <Tab>[
                  new Tab(child: new IconTheme(
                    data: new IconThemeData(
                        color: color1),
                    child: new Icon(Icons.home),
                  ),),
                  new Tab(child: new IconTheme(
                    data: new IconThemeData(
                        color: color1),
                    child: new Icon(Icons.arrow_downward),
                  ),),
                  new Tab(child: new IconTheme(
                    data: new IconThemeData(
                        color: color1),
                    child: new Icon(Icons.group),
                  ),),
                  new Tab(child: new IconTheme(
                    data: new IconThemeData(
                    color: color1),
                    child: new Icon(Icons.image),
                    ),),
                  /*new Tab(child: new IconTheme(
                    data: new IconThemeData(
                        color: color1),
                    child: new Icon(Icons.search),
                  ),)*/

                  //child: new IconTheme(
                  //    data: new IconThemeData(
                  //        color: Colors.yellow),
                  //    child: new Icon(Icons.home),
                  //),
                  //new Tab(icon: new Icon(Icons.home)),
                ]
            )
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new FeedPage.FeedPage(),
              new CreateDown.CreateDown(),
              new third.Third(),
              new MyApp(),
              //new SearchPage()
            ]
        )
    );
  }
}

