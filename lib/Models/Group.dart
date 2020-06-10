/*
Author: Conner Delahanty

Contains information about a group

Notes:

*/

import "package:down/Models/User.dart";

class Group {

  String name;
  List<String> memberIDs;
  List<User> members;
  int nMembers;

  bool invite = false;

  Group({this.name});

  String getMemberDisplay() {
    String output = "";
    for(int i = 0; i < members.length-1; i++) {
      output += members[i].toString() + ", ";
    }
    output+=members[members.length-1].toString();
    return output;
  }


}