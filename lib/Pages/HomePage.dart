import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/User.dart';
import 'package:down/Pages/FeedPage.dart' as FeedPage;
import 'package:down/Pages/CreateDown.dart' as CreateDown;
import 'package:down/Pages/BurgerPage.dart' as third;
import '../Widgets/MyApp.dart';


const color1 = const Color(0xff26c586);
const transColor = Color(0x00000000);
final usersReference = FirebaseDatabase.instance.reference().child("Users");
User currentUser;

final DateTime timestamp = DateTime.now();

class HomePage extends StatefulWidget {

  final FirebaseUser user;
  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // homepage variables
  PageController pageController;
  int getPageIndex = 0;


  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //return RaisedButton.icon(onPressed: null, icon: Icon(Icons.close), label: Text("Sign Out"));
    return new MyTabs();
  }

}


class MyTabs extends StatefulWidget {

  FirebaseUser user;
  MyTabs({this.user});
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