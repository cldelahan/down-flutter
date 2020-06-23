/*
  Author: Conner Delahanty

  This code creates a "give feedback" page, that we store in the database under
  the "feedback" section. Allows us to get numerical scale and a text comment.


  Notes:

 */

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  FirebaseUser user;

  FeedbackPage(this.user);

  @override
  _FeedbackPageState createState() => _FeedbackPageState(this.user);
}

class _FeedbackPageState extends State<FeedbackPage> {
  FirebaseUser user;
  DatabaseReference dbFeedback;
  final _formKey = new GlobalKey<FormState>();

  _FeedbackPageState(this.user);

  int satisfied;
  bool anonymous = true;
  String feedback;

  @override
  void initState() {
    dbFeedback = FirebaseDatabase.instance.reference().child("feedback");
  }

  @override
  Widget build(BuildContext context) {
    return showForm();
  }

  Widget showForm() {
    return new Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: new Form(
            key: _formKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                showDownIntro(),
                showSatisfiedInput(),
                showFeedbackInput(),
                askBeAnonymous(),
                submitForm()
              ],
            )));
  }

  Widget showDownIntro() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new Column(children: <Widget>[
              new Text("Down Feedback!",
                  style: new TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Lato",
                      fontSize: 40.0)),
              new Text("How can we improve?")
            ]))));
  }

  Widget showSatisfiedInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                autofocus: false,
                validator: (value) {
                  int val = int.parse(value);
                  if (val < 0 || val > 10) {
                    return ('Value should be between 0 and 10');
                  }
                },
                onChanged: (value) {
                  this.satisfied = int.parse(value);
                },
                decoration: InputDecoration(
                    hintText: "How satisfied are you with Down?"))));
  }

  Widget showFeedbackInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: false,
                onChanged: (value) {
                  this.feedback = value;
                },
                decoration: InputDecoration(
                    hintText: "What do you love, hate, or doesn't work?"))));
  }

  Widget askBeAnonymous() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            child: new Row(children: <Widget>[
          new Text("Anonymous submission?"),
          Checkbox(
              onChanged: (bool newValue) {
                setState(() {
                  anonymous = newValue;
                });
              },
              value: anonymous)
        ])));
  }

  Widget submitForm() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new RaisedButton(
                    child: Text("Submit Feedback"),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      // before submitting make sure the form is valid
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      // if no image was specified set their image to default
                      DatabaseReference result = dbFeedback.push();
                      result.set({
                        "satisfaction": satisfied,
                        "feedback": feedback,
                      });
                      if (!anonymous) {
                        result.update({"user": user.uid});
                      }

                      // move to the homepage
                      Navigator.pop(context);
                    }))));
  }
}
