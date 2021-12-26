import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/input_field.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/components/logo.dart';
import 'package:firebasedemo/models/user.dart';
import 'package:firebasedemo/screens/register%20and%20login/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../static.dart';
import '../home.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();

  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(children: <Widget>[
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Logo(
                flex: 2,
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Spacer(),
                      InputField(controller: t1, hint: "Email"),
                      InputField(
                        controller: t2,
                        hint: "Şifre",
                        isObscure: true,
                      ),
                      const Spacer(),
                      LoginButton(),
                      RegisterTextButton(context),
                      const Spacer(),
                      const Spacer()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
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

  TextButton RegisterTextButton(BuildContext context) {
    return TextButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Register()));
          });
        },
        child: const Text(
          "Kayıt Ol",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ));
  }

  GestureDetector LoginButton() {
    return GestureDetector(
        onTap: () {
          isLoading = true;

          login();
          setState(() {});
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient:
                    const LinearGradient(begin: Alignment.centerLeft, colors: [
                  Colors.blue,
                  Colors.purple,
                ])),
            child: const Text(
              "Giriş Yap",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 20),
            )));
  }

  login() async {
    if (isLoading) {
      LoadingDialog();
    }

    try {
      UserCredential userCredential = await _userInstance
          .signInWithEmailAndPassword(email: t1.text, password: t2.text)
          .whenComplete(() => {});

      if (userCredential != null) {
        print("kullanıcı--------------------");
        Static.user.id = userCredential.user!.uid.toString();
        await _instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .get()
            .then((value) => {
                  Static.user.id = value.id,
                  print(value.data() == null ? "null" : "dolu"),
                  Static.user.name = value.data()!["name"],
                  Static.user.lastname = value.data()!["lastname"],
                  Static.user.email = value.data()!["email"],
                  Static.user.age = value.data()!["age"]
                })
            .whenComplete(() => {
                  print(Static.user.name.toString() +
                      Static.user.lastname.toString() +
                      Static.user.email.toString() +
                      Static.user.age.toString() +
                      Static.user.id.toString()),
                  isLoading = false,
                  Navigator.pop(context),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  ),
                  print("------------"),
                  setState(() {})
                });
      } else {
        print("kullanıcı--------------------");
        print(userCredential.user!.uid.toString());
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('kullanıcı bulunamadı');
      } else if (e.code == 'wrong-password') {
        print('wrong-password');
      }
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Center(child: Text("Kullanıcı bulunamadı")),
          content: Container(
              padding: EdgeInsets.all(8),
              height: 50,
              child: const Center(
                  child: Text(
                      "Email veya Parola Yanlış, Lütfen tekrar deneyiniz."))),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      isLoading = false;
      Navigator.pop(context);

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Center(child: const Text('Kullanıcı Bulunamadı')),
          content: SizedBox(
              height: 50,
              child: Center(
                child: Text("Bir hata oluştu, Lütfen tekrar deneyiniz."),
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
