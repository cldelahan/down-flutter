import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './FeedPage.dart' as first;
import './DownPage1.dart' as second;
import './BurgerPage.dart' as third;


const color1 = const Color(0xff26c586);
const transColor = Color(0x00000000);


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // keeping track if user is signed in
  bool isSignedIn = false;

  void initState() {
    super.initState();

    // if the user changes, try signing in with the account
    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignIn);
    }, onError: (gError) {
      print("Error Message:" + gError);
    });

    // if the user is already signed in, then let them sign in
    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSignIn(gSignIn);
    }).catchError((gError) {
      print("Error Message: " + gError);
    });
  }

  controlSignIn(GoogleSignIn signInAccount) async {
    if(signInAccount != null) {
      // create user account
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState((){
        isSignedIn  = false;
      });
    }
  }

  loginUser() {
    // signin user
    gSignIn.signIn();
    // if they are signed in - we need to check firebase
    // and switch pages
  }

  logoutUser() {
    gSignIn.signOut();
  }

  Widget buildHomeScreen() {
    //return RaisedButton.icon(onPressed: null, icon: Icon(Icons.close), label: Text("Sign Out"));
    return new MyTabs();
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container (
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Text ("Down",
            style: TextStyle(fontSize: 92.0, color: color1, fontFamily: "Signatra"),
            ),
            GestureDetector(
              onTap: ()=> "button tapped",
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
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Down"),
            backgroundColor: color1,

        ),
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
              new first.First(),
              new second.Second(),
              new third.Third()
            ]
        )
    );
  }
}

