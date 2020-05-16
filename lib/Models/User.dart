import 'package:firebase_database/firebase_database.dart';

// template class to model a user
// allows for better importing into Firebase
class User {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String token;

  User({
    this.id,
    this.profileName,
    // TODO: Do we want to distinguish between these two?
    this.username,
    this.url,
    this.email,
    this.token
  });

  ///
  /// populateDown takes a database reference at the level of the down and
  /// returns a Down object.
  /// Is it inefficient to recreate an array of downs anytime a down changes?
  /// Likely yes - but was the underlying component of Down 1.0
  ///
  static User populateUser(DataSnapshot ds) {
    Map entry = ds.value;
    return User(
        id: ds.key,
        profileName: entry['profileName'],
        url: entry['url'],
        email: entry['email']
    );
  }
}