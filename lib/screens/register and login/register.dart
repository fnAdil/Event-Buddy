import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/components/input_field.dart';
import 'package:firebasedemo/components/logo.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  TextEditingController t4 = TextEditingController();
  TextEditingController t5 = TextEditingController();

  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;
  late User _user;
  bool isLoading = false;
  final picker = ImagePicker();
  late File _imageFile;
  String link = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: <Widget>[
        const Background(),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Logo(flex: 1),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () async {
                          await pickImage();
                        },
                        child: const Text(
                          "Fotoğraf yükle",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )),
                    InputField(
                      controller: t1,
                      hint: "Email",
                    ),
                    InputField(
                      controller: t2,
                      hint: "Şifre",
                      isObscure: true,
                    ),
                    InputField(
                      controller: t3,
                      hint: "Ad",
                    ),
                    InputField(
                      controller: t4,
                      hint: "Soyad",
                    ),
                    InputField(
                      controller: t5,
                      hint: "Yaş",
                    ),
                    registerButton(),
                    loginTextButton(context)
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future uploadImage(BuildContext context, String id) async {
    String fileName = _imageFile.path;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(id)
        .child('profilePhoto');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_imageFile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        _instance.collection("users").doc(id).update({"profilePhoto": value});
        link = value;
        print("Completed: $value");
      },
    );
  }

  Future<String?> loadingDialog() {
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
            children: const [
              CircularProgressIndicator(),
              Text("Yükleniyor...")
            ],
          ),
        ),
      ),
    );
  }

  register() async {
    if (isLoading) {
      loadingDialog();
    }
    String errorMessage = "Bir hata Oluştu!";
    try {
      await _userInstance
          .createUserWithEmailAndPassword(email: t1.text, password: t2.text)
          .then((value) async {
        await uploadImage(context, value.user!.uid);
        _instance.collection("users").doc(value.user?.uid.toString()).set({
          "name": t3.text,
          "lastname": t4.text,
          "age": t5.text,
          "email": t1.text,
          "passcode": t2.text,
          "profilePhoto": link
        }).whenComplete(() => {
              setState(() {
                print("kullanıcı kaydedildi");
                isLoading = false;
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              })
            });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = "Parola çok güçsüz, Lütfen tekrar deneyiniz.";
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        errorMessage =
            "Bu email adresi ile kayıtlı bir kullanıcı vardır, Lütfen tekrar deneyiniz.";
        print('The account already exists for that email.');
      }
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Center(child: Text('Kullanıcı Bulunamadı')),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Mevcut Kullanıcı'),
          content: const Text(
              'Bu email alınmış durumda, giriş yapmak için Login butonuna basınız.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login())),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }
  }

  TextButton loginTextButton(BuildContext context) {
    return TextButton(
        onPressed: () {
          setState(() {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          });
        },
        child: const Text(
          "Giriş Yap",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ));
  }

  GestureDetector registerButton() {
    return GestureDetector(
        onTap: () {
          if (_imageFile.path == "") {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Center(child: Text('Fotoğraf Bulunamadı')),
                content: const Text(
                    "Fotoğraf yüklemek zorunludur, Lütfen bir fotoğraf seçin."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            setState(() {
              isLoading = true;

              register();
            });
          }
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            decoration: BoxDecoration(
                gradient:
                    const LinearGradient(begin: Alignment.centerLeft, colors: [
                  Colors.blue,
                  Colors.purple,
                ]),
                borderRadius: BorderRadius.circular(25),
                color: Colors.purple[400]),
            child: const Text(
              "Kaydol",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 20),
            )));
  }
}
