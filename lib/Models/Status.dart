/*
  Author: Conner Delahanty

  This exists to model a Down Status. These are used to populate the DownEntryDetails
  page.

  Notes:

 */
import 'package:down/Models/User.dart';

class Status {
  User poster;
  String status;
  Set<String> likerUids = new Set();
  int nUpvoted = 0;

  bool likedByUser = false;


  void countLikers(Map likeData) {
    if (likeData == null) {
      nUpvoted = 0;
      return;
    }
    for (String liker in likeData.keys) {
      likerUids.add(liker);
      nUpvoted += 1;
    }
  }

  bool altLikeByUser() {
    if (likedByUser) {
      nUpvoted--;
    } else {
      nUpvoted++;
    }
    likedByUser = !likedByUser;
    return likedByUser;
  }


  int compareTo(Status other) {
    if (this.nUpvoted > other.nUpvoted) {
      return 1;
    } else {
      return 0;
    }
  }
}