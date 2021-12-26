import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/home.dart';
import 'package:firebasedemo/screens/register%20and%20login/register.dart';
import 'package:firebasedemo/static.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/register and login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final _userInstance = FirebaseAuth.instance;
    final _instance = FirebaseFirestore.instance;
    return MaterialApp(
      title: 'Event Friends',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Colors.purple,
      ),
      home: _userInstance.currentUser == null ? Login() : Home(),
    );
  }
}
