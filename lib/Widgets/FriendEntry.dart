import 'package:flutter/material.dart';
import 'package:down/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendEntry extends StatelessWidget {
  FirebaseUser user;
  User friend;

  FriendEntry(this.user, this.friend);

  @override Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
        child:
        GestureDetector(
            onTap: () {
              // TODO: Go to friend profile page
              print("Tapping user");
            },
            child: Container(
                color: Colors.white,
                child: Row(
                    children: <Widget>[
                      Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(friend.url)
                              )
                          )
                      ),
                      SizedBox(width: 10.0),
                      Text(friend.profileName,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: "Lato"
                          ))
                    ]
                ))

        )
    );
  }
}
