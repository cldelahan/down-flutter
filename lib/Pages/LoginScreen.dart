/*
  Author: Conner Delahanty

  Code creates a login screen (with phone number input) and asks user for input

  Notes:
    Firebase phone authentication code adapted from Maaz Aftab's article,
    https://medium.com/flutterpub/firebase-user-authentication-using-phone-verification-in-flutter-c34dc0f7a9f8


 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:down/Pages/HomePage.dart';
import 'package:down/Pages/UserInfoPage.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final bool bypass = false;

  GlobalKey _scaffoldKey;

  FirebaseAuth auth = FirebaseAuth.instance;

  /*
    This function logs in the user using their phone number and Firebase
    authentication.
   */
  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    // Filling in FirebaseAuthentication function
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        // if the automatic authentication works properly, this function is
        // called
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await _auth.signInWithCredential(credential);

          Navigator.of(context).pop();
          FirebaseUser user = result.user;

          if (user != null) {
            // if the user is a new user, go to the UserInfoPage (to get
            // additional information)
            if (result.additionalUserInfo.isNewUser) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserInfoPage(
                        user: user,
                      )));
            } else {
              // else jump directly to the homepage (tab view)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(
                            user,
                          )));
            }
          } else {
            print("Error");
          }
        },
        // callback if verification fails
        // TODO: put out clean "sorry incorrect code message"
        verificationFailed: (AuthException exception) {
          print(exception);
        },
        // function if we send out the manual verification code
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Scaffold(
                    key: _scaffoldKey,
                    body: AlertDialog(
                      title: Text("Enter One-Time-Code"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: _codeController,
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Confirm"),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            final code = _codeController.text.trim();
                            AuthCredential credential =
                                PhoneAuthProvider.getCredential(
                                    verificationId: verificationId,
                                    smsCode: code);

                            AuthResult result =
                                await _auth.signInWithCredential(credential);

                            FirebaseUser user = result.user;

                            if (user != null) {
                              // if the user is a new user, go to the UserInfoPage (to get
                              // additional information)
                              if (result.additionalUserInfo.isNewUser) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserInfoPage(
                                          user: user,
                                        )));
                              } else {
                                // else jump directly to the homepage (tab view)
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomePage(
                                              user,
                                            )));
                              }
                            } else {
                              print("Error");
                            }
                          },
                        )
                      ],
                    ));
              });
        },
        codeAutoRetrievalTimeout: null);
  }


  void dispose() {
    _codeController.dispose();
    _phoneController.dispose();
  }


  Widget showPhoneNumberInput() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: InternationalPhoneNumberInput(
          textFieldController: _phoneController,
          countries: ["US"],
          textStyle: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
          onInputChanged: (PhoneNumber number) {
            // Can be used if multiple countries are desired
            // (since PhoneNumber number above adds country selector)
          },
        )
    );
  }

  Widget showLogo() {
    return new Hero(
        tag: 'hero',
        child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
            child: Image.asset("assets/images/DownLogo.png")
            )
    );
  }

  void _autoSignin(BuildContext context) async {
    FirebaseUser curUser = await auth.currentUser();
    print("Autosignin User attempt: " + curUser.toString());
    if (curUser == null) {
      print("Cur user is void");
      return;
    } else {
      print("Cur user autosigned-in");
      // user is not null so we can go to homepage
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                curUser,
              )));
    }

  }


  @override
  Widget build(BuildContext context) {
    if (bypass) {
      return UserInfoPage();
    }
    _autoSignin(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              showLogo(),
              SizedBox(
                height: 16,
              ),
              showPhoneNumberInput(),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("LOGIN / SIGNUP"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    // Hardcoded for US
                    final phone = "+1"+_phoneController.text.trim();
                    loginUser(phone, context);
                  },
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
