/*
Author: Conner Delahanty

If a recently signed-in user is "new", he / she will provide info on this page
(name, profile name, profile pic, etc.)

Notes:
  This was designed to be seen only after the sign-in page. This could be reused
  or abstracted so can be used to change profile information in settings page.

*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Pages/FeedPage.dart';
import 'package:url_launcher/url_launcher.dart';

class UserInfoPage extends StatefulWidget {
  FirebaseUser user;

  UserInfoPage({this.user});

  _UserInfoPageState createState() => _UserInfoPageState(this.user);
}

class _UserInfoPageState extends State<UserInfoPage> {
  // the user object we get from the login screen
  FirebaseUser user;

  // these are variables we will eventually store in firebase
  String _email;
  String _profileName;
  String _imageURL;
  File _imageFile;
  bool _importContacts = false;
  bool _showClear = false;

  // keys to validate form
  final _formKey = new GlobalKey<FormState>();

  // reference to the user database
  final dbUsers = FirebaseDatabase.instance.reference().child('users');

  // read the user from the StatefulWidget (Constructor)
  _UserInfoPageState(this.user);

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
                showNameInput(),
                showEmailInput(),
                askImportContacts(),
                uploadImage(),
                viewImage(),
                submitForm()
              ],
            )));
  }

  Widget showEmailInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                validator: (value) {
                  if (value.length == 0 ||
                      value.indexOf("@") < 0 ||
                      value.indexOf(".") < 0) {
                    return ('Invalid email');
                  }
                },
                // it is a little innefficient to update every change,
                // but worked and was easy. Could also look at onSaved
                onChanged: (value) {
                  this._email = value;
                },
                decoration: InputDecoration(hintText: "Enter email"))));
  }

  Widget showNameInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: false,
                validator: (value) {
                  if (value.length == 0) {
                    return ('Invalid name');
                  }
                },
                onChanged: (value) {
                  this._profileName = value;
                },
                decoration: InputDecoration(hintText: "Enter name"))));
  }

  Widget askImportContacts() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            child: Column(children: <Widget>[
          new Row(children: <Widget>[
            new Text("Import Contacts?"),
            Checkbox(
                onChanged: (bool newValue) {
                  setState(() {
                    _importContacts = newValue;
                    print("Output: " + _importContacts.toString());
                  });
                },
                value: _importContacts)
          ]),
          new Text(
            "(Notice: by choosing to import contacts you agree to our privacy policy)",
            style: TextStyle(
              fontSize: 12.0,
              fontFamily: "Lato",
              fontWeight: FontWeight.w300,
              color: Colors.grey,
            ),
          ),
          new Container(
              child: new InkWell(
            child: new Text("Privacy Policy",
                style: new TextStyle(
                  color: Theme.of(context).primaryColor,
                )),
            onTap: () => launch(
                'https://www.termsfeed.com/privacy-policy/530cdacf8e498b39874d5fea00a13d0c'),
          ))
        ])));
  }

  Widget submitForm() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new RaisedButton(
              child: Text("Create Account!"),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                // before submitting make sure the form is valid
                if (!_formKey.currentState.validate()) {
                  return;
                }
                // if no image was specified set their image to default
                if (_imageFile == null) {
                  this._imageURL =
                      'gs://down-flutter.appspot.com/nullavatar.png';
                } else {
                  // put photo in firebase
                  _uploadPhoto();
                  // fill out their database location
                  dbUsers.child(this.user.uid).update({
                    'email': this._email,
                    'profileName': this._profileName,
                    'url': this._imageURL,
                    'phone': this.user.phoneNumber,
                    'importContacts': this._importContacts
                  });
                  // move to the homepage
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeedPage(
                                user,
                              )));
                }
              },
            ))));
  }

  Widget showDownIntro() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new Column(children: <Widget>[
              new Text("Welcome to Down!",
                  style: new TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w300,
                      fontFamily: "Lato",
                      fontSize: 40.0)),
              new Text("Tell us about yourself!")
            ]))));
  }

  captureImageFromSource(ImageSource source) async {
    File selected = await ImagePicker.pickImage(
        source: source, maxHeight: 400, maxWidth: 400);
    setState(() {
      this._imageFile = selected;
      this._showClear = true;
    });
  }

  void _clear() {
    setState(() {
      _imageFile = null;
      _showClear = false;
    });
  }

  void _uploadPhoto() {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://down-flutter.appspot.com');
    String filePath = 'profileImages/${DateTime.now().millisecondsSinceEpoch.toString()}';
    this._imageURL = 'gs://down-flutter.appspot.com/' + filePath;
    _storage.ref().child(filePath).put(this._imageFile);
  }

  Widget uploadImage() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget> [
              new Text("Select profile picture",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: "Lato",
                fontWeight: FontWeight.w300,
                //color: Theme.of(context).primaryColor
                color: Colors.grey
              )),
            new Row( mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              new IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed: () => captureImageFromSource(ImageSource.camera)),
              new IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () => captureImageFromSource(ImageSource.gallery))
            ])])));
  }

  Widget viewImage() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Column(children: <Widget>[
              _imageFile != null
                  ? Image.file(_imageFile)
                  : new Container(color: Colors.transparent),
              _showClear == false
                  ? new Container(color: Colors.transparent)
                  : Row(children: <Widget>[
                      FlatButton(
                        child: Icon(Icons.refresh),
                        onPressed: _clear,
                      ),
                      // Use this if we want a manual upload of photo
                      /*FlatButton(
                        child: Icon(Icons.file_upload),
                        onPressed: _uploadPhoto,
                      )*/
                    ])
            ])));
  }
}
