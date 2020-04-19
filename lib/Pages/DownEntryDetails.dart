import 'package:flutter/material.dart';
import '../Models/Down.dart';
import '../Widgets/HeaderWidget.dart';
import '../Models/User.dart';
import '../Widgets/UserEntry.dart';

class DownEntryDetails extends StatelessWidget {
  final int num;
  final Down down;
  static User test1 = User(id: "c1", profileName: "Conner D", email: "conner@gmail.com", url: "http://connerdelahanty.com/ConnerDelahanty.jpg");
  static User test2 = User(id: "v1", profileName: "Vance W", email: "vance@gmail.comm", url: "https://hopkinssports.com/images/2019/10/22/Wood_Img1820.jpg?width=300");
  List<User> userEntries = [test1, test2];


  DownEntryDetails({Key key, this.num, this.down}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    AppBar appBar = header(context,
        isAppTitle: false, strTitle: down.title);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Hero(
        tag: num,
        child: Scaffold(
            appBar: appBar,
            body: Center (
              child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
                child: Stack(children: <Widget>[
                  Column(children: <Widget>[
                    Container(
                      color: down.isDown
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      child: Column(children: <Widget>[
                        Text(down.title,
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 5.0),
                        Row( children: <Widget> [
                          (down.address != null) ? Text(down.address,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                              )
                          ) : Container(),
                        ]
                        ),
                        SizedBox(height: 5.0),
                        Row(children: <Widget>[
                          Text(down.getCleanTime(),
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black)),
                        ]),
                        SizedBox(height: 30.0), // spacing between time and Down / Havent Seen / Invited
                        Text(down.getGoingSummary()),
                      ]
                      ),
                    ),
                    Container (
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return userEntry(context, userEntries[index], index);
                          },
                          itemCount: userEntries.length
                      ),
                    )
                  ],

                  ),
                  Container(
                    height: mediaQuery.padding.top,
                  ),
                ])))
        ));
  }
}
