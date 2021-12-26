// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/models/user.dart';

import 'package:firebasedemo/screens/register%20and%20login/login.dart';
import 'package:firebasedemo/screens/profile/requests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../static.dart';
import 'chats.dart';

class Messages extends StatefulWidget {
  const Messages({
    Key? key,
  }) : super(key: key);
  @override
  State<Messages> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<Messages> {
  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;
  late String userId;
  late String chatId;
  late Users sender;

  @override
  Widget build(BuildContext context) {
    userId = _userInstance.currentUser!.uid.toString();
    return Stack(children: <Widget>[
      const Background(),
      Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 80),
          child: StreamBuilder<QuerySnapshot>(
            stream: _instance
                .collection('mesajlar')
                .where("üyeler", arrayContains: userId)
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
                    List<dynamic> lst1 = doc.get("üyeler");
                    lst1.remove(userId);
                    String senderId = lst1.first;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          foregroundImage: AssetImage(
                            "assets/images/pp.png",
                          ),
                        ),
                        trailing: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text("1"),
                        ),
                        title: Text("${doc.get("konser")} "),
                        onTap: () async {
                          await _instance
                              .collection("users")
                              .doc(senderId)
                              .get()
                              .then((value) => {
                                    sender = Users(
                                        senderId,
                                        value.data()!["email"],
                                        value.data()!["name"],
                                        value.data()!["lastname"],
                                        value.data()!["age"])
                                  })
                              .whenComplete(() => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Chats(
                                                  chatId: doc.id,
                                                  userId: userId,
                                                  sender: sender,
                                                )))
                                  });
                        },
                      ),
                    );
                  }).toList(),
                );
            },
          )),
      Padding(
        padding:
            const EdgeInsets.only(top: 40.0, left: 10, right: 10, bottom: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.deepPurple),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Messages",
                style: TextStyle(fontSize: 25, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
