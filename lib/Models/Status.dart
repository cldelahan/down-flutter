/*
  Author: Conner Delahanty

  This exists to model a Down Status. These are used to populate the DownEntryDetails
  page.

  Notes:

 */

class DownStatus {
  String posterID;
  String posterName;
  String status;
  int nUpvoted = 0;

  DownStatus({this.posterID, this.posterName, this.status, this.nUpvoted});

  int compareTo(DownStatus other) {
    if (this.nUpvoted > other.nUpvoted) {
      return 1;
    } else {
      return 0;
    }
  }
}