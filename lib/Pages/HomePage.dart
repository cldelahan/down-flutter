import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/User.dart';
import 'package:down/Pages/FeedPage.dart';
import 'package:down/DownCreation/CreateDownActivityScreen.dart';
import 'package:down/Pages/FriendGroupPage.dart';
import '../Widgets/MyApp.dart';


final usersReference = FirebaseDatabase.instance.reference().child("Users");
User currentUser;

final DateTime timestamp = DateTime.now();

class HomePage extends StatefulWidget {

  final FirebaseUser user;
  HomePage(this.user);

  @override
  _HomePageState createState() => _HomePageState(this.user);
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  // homepage variables
  FirebaseUser user;
  PageController pageController;
  TabController tabController;
  int getPageIndex = 0;

  @override
  bool get wantKeepAlive => true;

  _HomePageState(this.user);


  @override
  void initState() {
    super.initState();
    setState((){});
    tabController = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    //return RaisedButton.icon(onPressed: null, icon: Icon(Icons.close), label: Text("Sign Out"));
    return new Scaffold(
        bottomNavigationBar: new Material(
            color: Colors.transparent,
            child: new TabBar(
                controller: tabController,
                tabs: <Tab>[
                  new Tab(child: new Icon(Icons.home)),
                  new Tab(child: new Icon(Icons.arrow_downward)),
                  new Tab(child: new Icon(Icons.group)),
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
            controller: tabController,
            children: <Widget>[
              new FeedPage(this.user),
              new CreateDownActivityScreen(this.user),
              new FriendGroupPage(this.user),
              //new SearchPage()
            ]
        )
    );
  }

}