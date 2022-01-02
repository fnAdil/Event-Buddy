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
    return Scaffold(
      appBar: AppBar(
        title: Text("Mesajlar"),
        centerTitle: true,
      ),
      body: Stack(children: <Widget>[
        const Background(),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
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
                      lst1.remove(Static.user.id);
                      String senderId = lst1.first;
                      List<dynamic> lst2 = doc.get("name");
                      lst2.remove(Static.user.name.toString() +
                          " " +
                          Static.user.lastname.toString());
                      String senderName = lst2.first;
                      List<dynamic> lst3 = doc.get("profilePhoto");
                      String senderPP;
                      if (lst3.remove(Static.user.profilePhoto)) {
                        senderPP = lst3.first;
                      } else {
                        senderPP = "";
                      }

                      return Card(
                        child: ListTile(
                          leading: senderPP == ""
                              ? CircleAvatar(
                                  foregroundImage:
                                      AssetImage("assets/images/person.png"),
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(senderPP),
                                ),
                          title: Text("${doc.get("konser")} "),
                          subtitle: Text("${senderName} "),
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
                                        value.data()!["age"],
                                        value.data()!["profilePhoto"],
                                      )
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
      ]),
    );
  }
}
