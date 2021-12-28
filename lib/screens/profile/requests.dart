// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/models/user.dart';
import 'package:firebasedemo/screens/messages/chats.dart';

import 'package:firebasedemo/screens/register%20and%20login/login.dart';
import 'package:firebasedemo/screens/profile/requests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../static.dart';

class Requests extends StatefulWidget {
  const Requests({
    Key? key,
  }) : super(key: key);

  @override
  State<Requests> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<Requests> {
  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    bool isError = false;
    return Scaffold(
      appBar: AppBar(
        title: Text("İstekler"),
        centerTitle: true,
      ),
      body: Stack(children: <Widget>[
        const Background(),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
            child: StreamBuilder<QuerySnapshot>(
              stream: _instance
                  .collection('users/${Static.user.id}/istekler')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else

                  // ignore: curly_braces_in_flow_control_structures
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      bool _customTileExpanded = false;
                      String senderId = doc.get("sender_id");

                      return Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          children: [
                            ExpansionTile(
                              leading: CircleAvatar(
                                foregroundImage: AssetImage(
                                  "assets/images/pp.png",
                                ),
                              ),
                              trailing: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Text("${doc.get("tarih")}"),
                              ),
                              title: Text("${doc.get("konser_ad")}"),
                              subtitle: Text("${doc.get("name")}"),
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                        child: Text(
                                          "Reddet",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          LoadingDialog();
                                          await _instance
                                              .collection(
                                                  "users/${Static.user.id}/istekler")
                                              .doc(doc.id)
                                              .delete()
                                              .whenComplete(() =>
                                                  {Navigator.pop(context)});

                                          setState(() {});
                                        }),
                                    TextButton(
                                        child: Text("Kabul et",
                                            style:
                                                TextStyle(color: Colors.green)),
                                        onPressed: () async {
                                          LoadingDialog();
                                          istekKabul(doc, isError, senderId,
                                              Static.user.id.toString());
                                        })
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
              },
            )),
      ]),
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

  Future<String?> ErrorDialog(String errorMessage) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Center(child: Text("Hata")),
        content: Container(
            padding: EdgeInsets.all(8),
            height: 80,
            child: Center(
                child: Text(
              errorMessage,
            ))),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: Center(child: const Text('OK')),
          ),
        ],
      ),
    );
  }

  Future istekKabul(
    QueryDocumentSnapshot<Object?> doc,
    bool isError,
    String senderId,
    String userId,
  ) async {
    List<dynamic> s;
    //düzelt
    await _instance
        .collection('mesajlar')
        .where("üyeler", arrayContains: userId)
        .get()
        .then((value) => {
              value.docs.forEach((element) => {
                    s = element.get("üyeler"),
                    print(doc.get("konser_id")),
                    print(element.get("konser_id")),

                    //aynı konser için aynı kişi ile mesajlaşma varsa ekleme yapma

                    if (element.get("konser_id") == doc.get("konser_id") &&
                        (s.first == doc.get("sender_id") ||
                            s.last == doc.get("sender_id")))
                      {
                        isError = true,
                      }
                  })
            })
        .whenComplete(() async => {
              //eğer herhangi bir sorun yoksa istek mesajlara eklenir ver buradan silinir.
              if (!isError)
                {
                  await _instance
                      .collection("mesajlar")
                      .add({
                        "konser": doc.get("konser_ad"),
                        "üyeler":
                            FieldValue.arrayUnion([Static.user.id, senderId]),
                        "konser_id": doc.get("konser_id"),
                        "name": FieldValue.arrayUnion([
                          Static.user.name.toString() +
                              Static.user.lastname.toString(),
                          doc.get("name")
                        ]),
                      })
                      .then((value) => {
                            _instance
                                .collection("mesajlar")
                                .doc(value.id)
                                .collection("mesaj")
                                .add({"mesaj": ""})
                          })
                      .whenComplete(() async => {
                            await _instance
                                .collection("users/${userId}/istekler")
                                .doc(doc.id)
                                .delete(),
                            Navigator.pop(context)
                          })
                }
              else
                {
                  await _instance
                      .collection("users/${userId}/istekler")
                      .doc(doc.id)
                      .delete()
                      .whenComplete(() => {Navigator.pop(context)})
                }
            });
    setState(() {});
  }
}
