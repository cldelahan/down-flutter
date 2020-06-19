/*
  Author: Conner Delahanty

  This page allows the user to see different businesses in their area,
  and subscribe to receive downs in their area.

  This feature gives the use additional value in seeing
  in-person specials from businesses, and have an easy way to invite
  people from these activities. This also keeps Down pages busy so there is
  no "left-outedness" and frustration. This feature encourages all people
  to be event planners.


  Also gives a business the ability to inform users of specials, and serves
  as a monitization opportunity for ourselves.

  Notes:

  Presently this is located as an additional tab. This could also replace the
  Friend/Group Page, or can be another tab of the Friend/Group Page.

  In Firebase, we keep a copy of all Businesses in "sponsored".
  They may post downs / details in "sponsoreddowns"

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/Organization.dart';
import 'package:down/Pages/SettingsPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:down/Models/User.dart';

class BusinessPage extends StatefulWidget {
  FirebaseUser user;

  BusinessPage(this.user);

  @override
  _BusinessPageState createState() => _BusinessPageState(this.user);
}

class _BusinessPageState extends State<BusinessPage> {
  FirebaseUser user;
  DatabaseReference dbOrganizations;
  DatabaseReference dbSubscribedOrganizations;

  List<String> subscribedOrgList = [];
  List<String> organizations = [];

  Map<String, Organization> organizationMap = {};


  _BusinessPageState(this.user);

  @override
  void initState() {
    subscribedOrgList = [];
    //Map<String, Organization> subMap;
    organizations = [];
    //Map<String, Organization> orgMap;

    dbOrganizations =
        FirebaseDatabase.instance.reference().child("sponsored/organizations");
    dbSubscribedOrganizations = FirebaseDatabase.instance
        .reference()
        .child("users/${this.user.uid}/subscribed");

    // TODO: switch to onValue?
    /*
    This allows us to pull in everything, manipulate it here, and then
    push back up to firebase the net change instead of doing many
    micro transactions.
     */
    dbSubscribedOrganizations.onChildAdded.listen(_onSubscriptionAdded);
    dbOrganizations.onChildAdded.listen(_onOrganizationAdded);
  }

  void _onSubscriptionAdded(Event event) async {
    DataSnapshot orgInfo =
        await dbOrganizations.child(event.snapshot.key).once();
    Organization org = Organization.populateFromDataSnapshot(orgInfo);

    subscribedOrgList.add(org.id);
    organizationMap.addAll({org.id : org});

    if (this.mounted) {
      setState(() {});
    }
  }

  void _onOrganizationAdded(Event event) {
    DataSnapshot orgInfo = event.snapshot;
    Organization org = Organization.populateFromDataSnapshot(orgInfo);

    organizations.add(org.id);
    organizationMap.addAll({org.id : org});

    if (this.mounted) {
      setState(() {});
    }
  }

  Widget organizationEntry(Organization o, bool isSubscription) {
    return GestureDetector(
        // TODO: decide the correct gestures for each organization
        onLongPress: () async {
          if (o.website == null || o.website == "") {
            return;
          }
          await launch(o.website);
        },
        onDoubleTap: () {
          if (isSubscription) {
            this.subscribedOrgList.remove(o.id);
            organizations.add(o.id);
            dbSubscribedOrganizations.child(o.id).remove();
            //organizations.add(o);
            setState(() {});
          } else {
            organizations.remove(o.id);
            // we don't add the value to the array because
            // the on-child added will do that.
            dbSubscribedOrganizations.update({o.id: 0});
            setState(() {});
          }
        },
        child: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 0.0),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.all(
                        color: Theme.of(context).accentColor, width: 1),
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                    leading: new Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: new BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: o.getImageOfOrganization()))),
                    title: Text(o.name,
                        style: Theme.of(context).textTheme.headline4),
                    subtitle: Text(o.about,
                        style: Theme.of(context).textTheme.bodyText2)))));
  }

  Widget displayHeadingText(String display) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Center(
            child:
                Text(display, style: Theme.of(context).textTheme.headline6)));
  }

  Widget makeAppBar() {
    return AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Down",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Lato",
            fontSize: 45.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(user)),
              );
            },
            child: Text("Profile"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ]);
  }

  Widget buildOrganizationDisplay(
      List<String> orgList, String emptyMessage, bool isSubscription) {
    return orgList.length == 0
        ? Padding(
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 20.0),
            child: Center(
                child: new Text(emptyMessage,
                    style: Theme.of(context).textTheme.bodyText1)))
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (orgList[index] == null) {
                return new Container(color: Colors.transparent);
              }
              return organizationEntry(organizationMap[orgList[index]], isSubscription);
            },
            itemCount: orgList.length,
          );
  }

  @override
  Widget build(BuildContext buildContext) {
    // TODO: this is a bad way to get rid of duplicates
    for (String orgID in subscribedOrgList) {
      organizations.remove(orgID);
    }
    return Scaffold(
        appBar: this.makeAppBar(),
        body: Column(children: <Widget>[
          displayHeadingText("--subscriptions--"),
          buildOrganizationDisplay(this.subscribedOrgList,
              "You are not subscribed to any organizations", true),
          displayHeadingText("--explore organizations--"),
          buildOrganizationDisplay(this.organizations,
              "There are no organizations available in your area", false)
        ]));
  }
}
