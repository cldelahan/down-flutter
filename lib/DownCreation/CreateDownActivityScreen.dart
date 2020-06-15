/*
  Author: Vance Wood, Conner Delahanty

  This page lets the user specify the activity they wish to do.

  Notes:

 */
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/RecommendedActivity.dart';
import 'package:down/Models/Down.dart';
import 'package:down/DownCreation/CreateDownTimeScreen.dart';

const color1 = const Color(0xff26c586);
String value = "";

class CreateDownActivityScreen extends StatefulWidget {
  final FirebaseUser user;

  CreateDownActivityScreen(this.user);

  @override
  _CreateDownActivityScreenState createState() =>
      _CreateDownActivityScreenState(this.user);
}

class _CreateDownActivityScreenState extends State<CreateDownActivityScreen>
    with AutomaticKeepAliveClientMixin {
  FirebaseUser user;
  DatabaseReference dbSponsoredActivities;
  List<RecommendedActivity> sponsoredActivities = [];
  List<RecommendedActivity> generalActivities = [];
  TextEditingController _nameController;
  bool wantKeepAlive = false;

  final _formKey = new GlobalKey<FormState>();

  Down _builtDown = new Down();

  _CreateDownActivityScreenState(this.user) {
    generalActivities.add(new RecommendedActivity(
        name: "Eat out", icon: Icons.fastfood, usingIcon: true));
    generalActivities.add(new RecommendedActivity(
        name: "Swim", icon: Icons.pool, usingIcon: true));
    generalActivities.add(new RecommendedActivity(
        name: "Exercise", icon: Icons.directions_run, usingIcon: true));
    generalActivities.add(new RecommendedActivity(
        name: "Read", icon: Icons.book, usingIcon: true));
    generalActivities.add(new RecommendedActivity(
        name: "Spa day", icon: Icons.spa, usingIcon: true));
  }


  @override
  void initState() {
    super.initState();
    print("Initializeing CreateDownActivityScreen");
    _nameController = new TextEditingController();
    dbSponsoredActivities =
        FirebaseDatabase.instance.reference().child("sponsored/activities");
    dbSponsoredActivities.onChildAdded.listen(_onSponsoredActivityAdded);

    // Populating the general activities with sample data
    // TODO: Sample this from database?
  }

  _onSponsoredActivityAdded(Event event) async {
    print(event.snapshot.key);
    print(event.snapshot.value);

    // add recommended activities
    setState(() {
      sponsoredActivities
          .add(RecommendedActivity.populateFromSnapshot(event.snapshot));
    });
  }


  Widget submitForm() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new RaisedButton(
                    child: Text("Continue"),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    onPressed: () {
                      // before submitting make sure the name is valid
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      print("Down name: " + _nameController.value.text.toString());
                      this._builtDown.title = _nameController.value.text.toString();

                      // move to the next page
                      Navigator.of(context).push(_createRoute());
                    }
                ))));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // since we don't have an app bar for this page, we
        // can wrap in "SafeArea" to not interfere with notification bar
        body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 25.0),
                    child: Column(children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            showDownNameInput(),
                            Text('Near you',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            SizedBox(
                              height: 3,
                            ),
                            Container(
                              height: 120,
                              child:
                                  recommendedActivityLine(sponsoredActivities),
                            )
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Recommended Activities',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            SizedBox(
                              height: 3,
                            ),
                            Container(
                              height: 120,
                              child: recommendedActivityLine(generalActivities),
                            )
                          ,
                          submitForm()]),
                    ])))));
  }

  Widget showDownNameInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 25.0),
        child: new Material(
          child: new Form(
            key: _formKey,
            child: TextFormField(
                controller: _nameController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: false,
                onChanged: (value) {
                  this._builtDown.title = value;
                },
                /*
                  This could (and should) be updated to avoid titles such as racist, extremist, and titles condoning violence
                   */
                validator: (value) {
                  if (value == null || value.length == 0) {
                    return "invalid down name";
                  }
                },
                decoration:
                    InputDecoration(hintText: "What do you want to do?")))));
  }

  Widget recommendedActivityLine(List<RecommendedActivity> raList) {
    return Scaffold(
        body: Center(
            child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        if (raList[index] == null) {
          return new Container(color: Colors.transparent);
        }
        return recommendedActivityEntry(
            raList[index], Theme.of(context).primaryColor);
      },
      itemCount: raList.length,
    )));
  }

// this widget turns a recommendedActivity object into a circular graphic
  Widget recommendedActivityEntry(RecommendedActivity ra, Color color) {
    return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () {
            this._builtDown.title = ra.name;
            print(ra.name);
            Navigator.of(context).push(_createRoute());
          },
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: ClipOval(
                    child: ra.usingIcon
                        ? Icon(ra.icon, size: 50)
                        : Image.network(
                            ra.smallGraphicUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                ra.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ));
  }

// this is creating a route between two pages
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          CreateDownTimeScreen(this.user, this._builtDown),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // a "tween" allows us to create an animation between the two pages
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        // this tween defined the movement between the two pages plus the
        // sigmoid curve effect
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
