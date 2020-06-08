import 'package:flutter/material.dart';
import '../Models/Down.dart';
import '../Pages/DownEntryDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image/firebase_image.dart';

class DownEntry extends StatefulWidget {
  Down down;

  DownEntry(this.down);

  @override
  _DownEntryState createState() => _DownEntryState(this.down);
}

class _DownEntryState extends State<DownEntry> {
  Down down;

  _DownEntryState(this.down);


  @override
  Widget build(BuildContext context) {
    return handmadeBuild(down, context);
    //return cardBuild(down, context);
  }

  Widget cardBuild(Down down, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
        child: Card(
            color: down.isDown ? Theme.of(context).primaryColor : Colors.white,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(

                leading: Container(
                    width: 40.0,
                    height: 20.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: this.down.creatorUrl
                                .startsWith("gs")
                                ? new FirebaseImage(
                                this.down.creatorUrl)
                                : new NetworkImage(
                                this.down.creatorUrl)))
                ),
                title: Text(this.down.title),
                subtitle: Text(this.down.getCleanTime().toString() +
                    '\n' +
                    this.down.nDown.toString() +
                    " down\t" +
                    this.down.nInvited.toString() +
                    " invited"),
              ),
              ButtonBar(children: <Widget>[
                FlatButton(child: const Text("Add to Calendar"), onPressed: (){print("You pressed ATC");}),
                FlatButton(child: const Text("Ignore"), onPressed: (){print("You pressed Ig");})
              ])
            ])));
  }

  Widget handmadeBuild(Down down, BuildContext context) {    print("Down toString(): " + this.down.toString());
  return Padding(
    padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
    child: GestureDetector(
      onTap:  () async {
        await Future.delayed(Duration(milliseconds: 200));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return new DownEntryDetails(down: down);
            },
            fullscreenDialog: true,
          ),
        );
        SnackBar snackBar = SnackBar(content: Text(down.title + " Tapped"), duration: Duration(seconds: 1));
        Scaffold.of(context).showSnackBar(snackBar);
      },
      onDoubleTap: () {
        // TODO
        // add down status to firebase

        setState(() {

          down.isDown = !down.isDown;

        });

        SnackBar snackBar = SnackBar(content: Text(down.isDown.toString()), duration: Duration(seconds: 1));
        Scaffold.of(context).showSnackBar(snackBar);
      },
      child: Container (
        color: down.isDown ? Theme.of(context).primaryColor : Colors.white,
        child: Column(
            children: <Widget>[
              Text(down.title,
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  )),
              Row(
                  children: <Widget> [
                    Text(down.getCleanTime(),
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey
                        )),
                    Flexible(fit: FlexFit.tight, child: SizedBox()),
                    Text(down.nInvited.toString() + " invited",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey,
                        )
                    )
                  ]
              ),
              Row(
                  children: <Widget> [
                    Text(down.creator,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        )
                    ),
                    Flexible(fit: FlexFit.tight, child: SizedBox()),
                    Text( DateTime.now().difference(down.timeCreated).inHours.toString() + "h ago",
                        style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey
                        )),
                    Flexible(fit: FlexFit.tight, child: SizedBox()),
                    Text("+" + down.nDown.toString(),
                        style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.black
                        ))
                  ]
              )
            ]
        ),
      ),
    ),
  );
  }


}
