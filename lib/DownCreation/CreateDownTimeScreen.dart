import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:down/Models/Down.dart';
import 'package:down/DownCreation/CreateDownInviteScreen.dart';
import 'package:firebase_database/firebase_database.dart';

// For changing the language
// ...

class CreateDownTimeScreen extends StatefulWidget {
  final FirebaseUser user;
  Down _builtDown;

  CreateDownTimeScreen(this.user, this._builtDown);

  @override
  _CreateDownTimeScreenState createState() =>
      _CreateDownTimeScreenState(this.user, this._builtDown);
}

class _CreateDownTimeScreenState extends State<CreateDownTimeScreen> {
  FirebaseUser user;
  Down _builtDown;

  _CreateDownTimeScreenState(this.user, this._builtDown);

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: new ListView(
            shrinkWrap: true, children: <Widget>[
              showPageIntro(),
              new Material(child:
              basicTimeField()),
        ]));
  }

  Widget showPageIntro() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new Column(children: <Widget>[
              new Text("Choose time",
                  style: new TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Lato",
                      fontSize: 40.0)),
            ]))));
  }

  Widget basicTimeField() {
    return Column(children: <Widget>[
      DateTimeField(
        format: DateFormat("hh:mm a"),
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          this._builtDown.time = DateTimeField.convert(time);
          this._builtDown.timeCreated = DateTime.now();
          Navigator.of(context).push(_createRoute());
          return;
        },
      ),
    ]);
  }

    Route _createRoute() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateDownInviteScreen(this.user, this._builtDown),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // a "tween" allows us to create an animation between the two pages
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          // this tween defined the movement between the two pages plus the
          // sigmoid curve effect
          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
              position: offsetAnimation,
              child: child
          );
        },
      );
    }
  }

