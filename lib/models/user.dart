import 'package:firebase_auth/firebase_auth.dart';

class Users {
  String? id;

  String? name;
  String? lastname;
  String? email;
  String? age;
  String? profilePhoto;
  Users(this.id, this.email, this.name, this.lastname, this.age,
      this.profilePhoto);
}
