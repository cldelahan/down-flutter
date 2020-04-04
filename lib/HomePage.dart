import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './CreateAccountPage.dart';
import './User.dart';
import './FeedPage.dart' as first;
import './DownPage1.dart' as second;
import './BurgerPage.dart' as third;


const color1 = const Color(0xff26c586);
const transColor = Color(0x00000000);
final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
User currentUser;

final DateTime timestamp = DateTime.now();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // keeping track if user is signed in
  bool isSignedIn = true;

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
      // create user account in firebase
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState((){
        isSignedIn  = false;
      });
    }
  }

  saveUserInfoToFireStore() async {
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    // get the snapshot of data from firebase user
    DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();
    // if they do not have an account
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
      usersReference.document(gCurrentUser.id).setData({
        "id": gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "userName": gCurrentUser,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp
      });

      documentSnapshot = await usersReference.document(gCurrentUser.id).get();
    }

    currentUser = User.fromDocument(documentSnapshot);
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

