/*
  Author: Conner Delahanty

  This exists to model a Down Status. These are used to populate the DownEntryDetails
  page.

  Notes:

 */

import 'package:down/Models/User.dart';

class Status {

  String status;
  Set<String> likerUIDs;
  // is duplicated data but is much easier
  User poster;


  Status({
    this.status = "",
});

  void setLikerUIDs (Set<String> likerUIDs) {
    this.likerUIDs = likerUIDs;
  }

  int getNumberOfLikes() {
    return likerUIDs.length;
  }

  int compareTo(Status other) {
    if (this.getNumberOfLikes() > other.getNumberOfLikes()) {
      return 1;
    } else {
      return 0;
    }
  }

  bool isLikedByUser(String uid) {
    return likerUIDs.contains(uid);
  }

  static Status populateFromMap(Map m) {
    String status = m["text"];
    Status temp = new Status (status: status);

    if (m["likes"] == null) {
      temp.setLikerUIDs({});
      return temp;
    }

    Map likeMap = Map<String, int>.from(m["likes"]);
    List<String> likerUIDs = List<String>.from(likeMap.keys);
    temp.setLikerUIDs(likerUIDs.toSet());

    return temp;
  }
}