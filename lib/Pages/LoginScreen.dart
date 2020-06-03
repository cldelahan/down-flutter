import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:down/Pages/HomePage.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  GlobalKey _scaffoldKey;

  Future<bool> loginUser(String phone, BuildContext context) async {
    print("OUTPUT" + phone);
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {

          AuthResult result = await _auth.signInWithCredential(credential);

          Navigator.of(context).pop();
          FirebaseUser user = result.user;

          if (user != null) {
            print("User is successful (automatically)");
            print("Output user: " + user.uid);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          user: user,
                        )));
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done automatically
        },
        verificationFailed: (AuthException exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Scaffold(
                    key: _scaffoldKey,
                    body: AlertDialog(
                      title: Text("Give the code?"),
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
                              print("Output user: " + user.uid);
                              print("User is successful (manually)");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage(
                                            user: user,
                                          )));
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


  @override
  Widget build(BuildContext context) {
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
