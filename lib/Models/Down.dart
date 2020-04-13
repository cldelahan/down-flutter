import 'package:cloud_firestore/cloud_firestore.dart';

// template class to model a user
// allows for better importing into Firebase
class Down {
  final String id;
  final String creator;
  final List<String> invited;
  final int nDown;
  final int nInvited;
  final DateTime time;
  final DateTime timeCreated;
  final String title;
  final String address;
  final String advertId;
  // isDown shouldn't normally be stored here
  bool isDown = false;

  Down({
    this.id,
    this.creator,
    this.invited,
    this.nDown,
    this.nInvited,
    this.time,
    this.timeCreated,
    this.title,
    this.address,
    this.advertId,
    this.isDown
  });

  String getCleanTime() {
    String minute = this.time.minute.toString();
    String hour = this.time.hour.toString();
    String todayOrTom = this.time.day == DateTime.now().day ? "Today" : "Tomorrow";
    String amPm = this.time.hour > 11 ? "pm" : "am";

    if (minute.length == 1) {
      minute = "0" + minute;
    }
    if (hour.length == 1) {
      hour = "0" + hour;
    }

    return todayOrTom + "  " + hour+ ":" + minute + " " + amPm;
  }

  factory Down.fromDocument(DocumentSnapshot doc) {
    return Down(
      id: doc.documentID,
      creator: doc['creator'],
      invited: doc['invited'],
      nDown: doc['nDown'],
      nInvited: doc['nInvited'],
      time: doc['time'],
      timeCreated: doc['timeCreated'],
      title: doc['title'],
      address: doc['address'],
      advertId: doc['advertID']
    );
  }
}