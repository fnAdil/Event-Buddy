import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/register and login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

/* Bu sınıf uygulamamızın ana kısmıdır.
  burada uygulamanın temel renkleri, ismi gibi bilgiler yer almaktadır
    */

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userInstance = FirebaseAuth.instance;
    return MaterialApp(
      title: 'Event Friends',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Colors.purple,
      ),
      //bu kısımda oturum açmış bir kullanıcı var mı diye kontrol yapılmaktadır.
      //var ise direkt ana sayfaya, yok ise giriş sayfasına yönlendirme yapılmaktadır.
      home: _userInstance.currentUser == null ? Login() : const Home(),
    );
  }
}
