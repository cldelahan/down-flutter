import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:down/Models/Down.dart';
import 'package:down/DownCreation/CreateDownInviteScreen.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
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
  Duration _duration = Duration();

  _CreateDownTimeScreenState(this.user, this._builtDown);

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: (DragStartDetails d) {
              Navigator.of(context).push(_createRoute());
            },
            child: Center(
              child: new GestureDetector(
                  onVerticalDragUpdate: (_) {},
                  child: TimePickerSpinner(
                  is24HourMode: false,
                  isForce2Digits: true,
                  spacing: 50,
                  normalTextStyle: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).secondaryHeaderColor),
                  highlightedTextStyle: TextStyle(
                      fontSize: 32, color: Theme.of(context).primaryColor),
                  onTimeChange: (time) {
                    setState(() {
                      _builtDown.time = time;
                      _builtDown.timeCreated = DateTime.now();
                    });
                  }),
            ))));
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
          // this is the set time from the widget (though date is 01/01/01)
          DateTime temp = DateTimeField.convert(time);
          // now we create a new time with some fields being today / tomorrow
          // with their time
          DateTime downTime;
          if (temp.hour > DateTime.now().hour) {
            // is today
            downTime = new DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, temp.hour, temp.minute, 0);
          } else {
            // is tomorrow
            downTime = new DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, temp.hour, temp.minute, 0);
            downTime = downTime.add(new Duration(days: 1));
          }

          this._builtDown.time = downTime;
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
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
