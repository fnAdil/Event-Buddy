import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/models/user.dart';
import 'package:firebasedemo/screens/events/Events.dart';
import 'package:firebasedemo/screens/messages/messages.dart';
import 'package:firebasedemo/screens/profile/profile.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../static.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _navBarIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;
  bool isUserDataTaken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _navBarIndex = value;
            });
          },
          children: <Widget>[
            Messages(),
            Events(),
            isUserDataTaken
                ? Profile()
                : Expanded(
                    child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        CircularProgressIndicator(),
                        Text("Yükleniyor...")
                      ],
                    ),
                  ))
          ]),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  kullaniciVerileriAl() async {
    print("test0-------" + _userInstance.currentUser!.uid);
    await _instance
        .collection("users")
        .doc(_userInstance.currentUser!.uid)
        .get()
        .then((value) => {
              Static.user.id = _userInstance.currentUser!.uid,
              print(value.data() == null ? "null" : "dolu"),
              //print(value.data()!["name"]),
              Static.user.name = value.data()!["name"],
              print(Static.user.name.toString()),
              Static.user.lastname = value.data()!["lastname"],
              print(Static.user.lastname.toString()),
              Static.user.email = value.data()!["email"],
              print(Static.user.email.toString()),
              Static.user.age = value.data()!["age"],
              print(Static.user.age.toString()),
              Static.user.profilePhoto = value.data()!["profilePhoto"],
              print(Static.user.profilePhoto.toString()),
            })
        .whenComplete(() => {});
    setState(() {
      isUserDataTaken = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("test1----------" + Static.user.id.toString());
    if (Static.user.name != null) {
      isUserDataTaken = true;
    } else {
      isUserDataTaken = false;
      kullaniciVerileriAl();
    }
    setState(() {});
  }

  Future<String?> LoadingDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        content: Expanded(
          child: Container(
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
      ),
    );
  }

  BottomNavigationBar BottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _navBarIndex,
      onTap: (value) {
        setState(() {
          _navBarIndex = value;
          _pageController.jumpToPage(_navBarIndex);
        });
      },
      backgroundColor: Colors.blue[200],
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              color: _navBarIndex == 0 ? Colors.deepPurple : Colors.black,
            ),
            title: Text(
              "Mesajlar",
              style: TextStyle(
                  color: _navBarIndex == 0 ? Colors.deepPurple : Colors.black),
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.event,
              color: _navBarIndex == 1 ? Colors.deepPurple : Colors.black,
            ),
            title: Text(
              "Etkinlikler",
              style: TextStyle(
                  color: _navBarIndex == 1 ? Colors.deepPurple : Colors.black),
            )),
        BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _navBarIndex == 2 ? Colors.deepPurple : Colors.black),
            title: Text(
              "Profil",
              style: TextStyle(
                  color: _navBarIndex == 2 ? Colors.deepPurple : Colors.black),
            ))
      ],
    );
  }
}
