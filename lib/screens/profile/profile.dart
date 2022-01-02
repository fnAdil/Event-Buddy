import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/components/profile_item.dart';
import 'package:firebasedemo/screens/register%20and%20login/login.dart';
import 'package:firebasedemo/screens/profile/requests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../static.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;
  final picker = ImagePicker();
  late File _imageFile;

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future uploadImage(BuildContext context) async {
    String fileName = _imageFile.path;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("${Static.user.id}")
        .child('profilePhoto');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_imageFile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        Static.user.profilePhoto = value;
        _instance
            .collection("users")
            .doc(Static.user.id)
            .update({"profilePhoto": value});

        print("Completed: $value");
      },
    );
  }

  Future deleteImage(BuildContext context) async {
    String fileName = _imageFile.path;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("${Static.user.id}");
    await firebaseStorageRef.delete();
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Background(),
        Column(
          children: [
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(top: 40, left: 30, right: 30),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: GestureDetector(
                      onTap: () async {
                        await pickImage()
                            .then((value) => null)
                            .whenComplete(() async {
                          await uploadImage(context);
                        });

                        setState(() {});
                      },
                      child: Static.user.profilePhoto == ""
                          ? CircleAvatar(
                              radius: 100,
                              foregroundImage:
                                  AssetImage("assets/images/person.png"),
                            )
                          : CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(
                                  Static.user.profilePhoto.toString()),
                            ),
                    ),
                  ),
                )),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    ProfileItem(
                      title: "Ad Soyad",
                      info: Static.user.name.toString() +
                          " " +
                          Static.user.lastname.toString(),
                    ),
                    ProfileItem(
                      title: "Email",
                      info: Static.user.email.toString(),
                    ),
                    ProfileItem(
                      title: "Yaş",
                      info: Static.user.age.toString(),
                    ),
                    goRequests(),
                    logOut(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  signOut() async {
    LoadingDialog();

    await _userInstance.signOut().then((value) => {
          Navigator.pop(context),
          Navigator.pop(context),
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()))
        });
  }

  Future<String?> LoadingDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
          ),
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CircularProgressIndicator(), Text("Yükleniyor...")],
          ),
        ),
      ),
    );
  }

  GestureDetector goRequests() {
    return GestureDetector(
      onTap: () {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Requests()),
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2.5),
        child: Container(
            decoration: (BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.purple,
                      Colors.blue,
                    ]))),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      "İstekler",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Icon(Icons.arrow_forward_ios),
                  )
                ],
              ),
            )),
      ),
    );
  }

  GestureDetector logOut() {
    return GestureDetector(
      onTap: () {
        setState(() {
          signOut();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2.5),
        child: Container(
            decoration: (BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.purple,
                      Colors.blue,
                    ]))),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      "Çıkış yap",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Icon(Icons.logout),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
