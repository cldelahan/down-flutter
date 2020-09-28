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
import 'package:down/Pages/HomePage.dart';
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
  // (alternatively we could store in User object and have a
  // ... .pushToFirebase() function)
  String _email;
  String _profileName;
  String _imageURL;
  File _imageFile;
  bool _importContacts = false;
  bool _showClear = false;

  Map allUserMap;
  DatabaseReference dbUsers;
  DatabaseReference dbDowns;

  final _formKey = new GlobalKey<FormState>();

  _UserInfoPageState(this.user);

  @override
  void initState() {
    super.initState();
    dbUsers = FirebaseDatabase.instance.reference().child("users");
    dbDowns = FirebaseDatabase.instance.reference().child("downs");
    dbUsers.onValue.listen(_getAllUsers);
  }

  void _getAllUsers(Event event) {
    // storing all users for our pretty nasty merge below
    // this in no regards should be this nasty
    DataSnapshot userDS = event.snapshot;
    allUserMap = userDS.value;
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
              onPressed: () async {
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
                  await dbUsers.child(this.user.uid).update({
                    'email': this._email,
                    'profileName': this._profileName,
                    'url': this._imageURL,
                    'phone': this.user.phoneNumber,
                    'importContacts': this._importContacts
                  });
                  // before moving to homepage, need to perform a nasty merge
                  // to check if this user already is listed
                  await _mergePotentialDuplicates();

                  // move to the homepage
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
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
    String filePath =
        'profileImages/${DateTime.now().millisecondsSinceEpoch.toString()}';
    this._imageURL = 'gs://down-flutter.appspot.com/' + filePath;
    _storage.ref().child(filePath).put(this._imageFile);
  }

  Widget uploadImage() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text("Select profile picture",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w300,
                          //color: Theme.of(context).primaryColor
                          color: Colors.grey)),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new IconButton(
                            icon: Icon(Icons.photo_camera),
                            onPressed: () =>
                                captureImageFromSource(ImageSource.camera)),
                        new IconButton(
                            icon: Icon(Icons.photo_library),
                            onPressed: () =>
                                captureImageFromSource(ImageSource.gallery))
                      ])
                ])));
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

  Future<void> _mergePotentialDuplicates() async {
    /*
      This is a really really nasty function.

      When creating an account, there is a chance you were
      already added as a user by someone else (so they can send you
      downs through text). After we authenticated you with a phone number,
      we go through and change all your earlier "friends" to have your new
      UID. We also delete the old phone account, so you keep all your downs
      and there is a seamless transition from a "phone-Downer" and a true
      user.

      Steps:
      1) Search through our above-generated map for a user with the same
      phone number.
      2) If there is no user with same phone number, this is a new user
      and we can continue on.
      3) Go through the UID's aliases (how we can track friends for phone-added
      users). For each UID in the aliases, replace the above UID with our new
      one (after account creation)
      4) Go through the UID's downs, and for each one, replace the invited with
      the new UID.
      5) TODO: Technically we should changed the user's statuses, etc. But we
      TODO: ... will ignore this for now (can justfiy by not letting people
      TODO: ... post statuses / liking statuses through texts).
      6) Replace add Down names to the new user
      7) Delete old user.
     */

    // Step 1
    String existingUID;
    List<String> allUserUIDs = List<String>.from(allUserMap.keys);
    for (String uid in allUserUIDs) {
      if (allUserMap[uid]["phone"] == this.user.phoneNumber &&
          uid != this.user.uid) {
        existingUID = uid;
        break;
      }
    }

    // Step 2
    if (existingUID == null) {
      return;
    }
    print("Existing UID found: " + existingUID);

    // Step 3
    if (allUserMap[existingUID]["aliases"] == null) {
      return;
    }
    List<String> aliasesUIDs =
        List<String>.from(allUserMap[existingUID]["aliases"].keys);
    for (String friendUID in aliasesUIDs) {
      // remove old UID
      dbUsers.child(friendUID).child("friends").child(existingUID).remove();
      // add new UID
      dbUsers.child(friendUID).child("friends").update({this.user.uid: 0});
      print("Removed alias");
      print(friendUID);
    }

    // Step 4 / 5
    if (allUserMap[existingUID]["downs"] == null) {
      return;
    }
    List<String> downUIDs =
        List<String>.from(allUserMap[existingUID]["downs"].keys);
    for (String downUID in downUIDs) {
      // removing old down
      DataSnapshot oldDownInfo = await dbDowns
          .child(downUID)
          .child("invited")
          .once();
      print(oldDownInfo.key);
      print(oldDownInfo.value);
      bool priorDownStatus = oldDownInfo.value[existingUID];
      print(priorDownStatus);
      dbDowns.child(downUID).child("invited").child(existingUID).remove();
      dbDowns
          .child(downUID)
          .child("invited")
          .update({this.user.uid: priorDownStatus});
      dbUsers.child(this.user.uid).child("downs").update({downUID: 0});
      print("Fixing downs");
    }
    // Step 6
    //dbUsers.child(existingUID).remove();

    // And the surgury is complete
  }
}
