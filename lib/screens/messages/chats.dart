import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/components/input_field.dart';
import 'package:firebasedemo/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  const Chats(
      {Key? key,
      required this.userId,
      required this.chatId,
      required this.sender})
      : super(key: key);
  final String userId;
  final String chatId;
  final Users sender;

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;

  late CollectionReference _ref;

  void initState() {
    _ref =
        _instance.collection("mesajlar").doc(widget.chatId).collection("mesaj");

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final _instance = FirebaseFirestore.instance;
    final _userInstance = FirebaseAuth.instance;

    TextEditingController t1 = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.sender.profilePhoto.toString()),
            ),
            SizedBox(
              width: 10,
            ),
            Text("${widget.sender.name} ${widget.sender.lastname}")
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: <Widget>[
            Background(),
            Container(
              child: Column(
                children: [
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: _ref.orderBy("date", descending: false).snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      print("gelen11111----" + "${snapshot.hasData}");
                      print("gelen11111----" + "${widget.chatId}");
                      print("gelen11111----" + "${widget.userId}");
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.docs
                                        .elementAt(index)
                                        .get("mesaj") !=
                                    "" &&
                                snapshot.data!.docs
                                        .elementAt(index)
                                        .get("mesaj") !=
                                    " ") {
                              return ListTile(
                                title: Align(
                                  alignment: widget.userId ==
                                          snapshot.data!.docs
                                              .elementAt(index)
                                              .get("sender")
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: widget.userId ==
                                                snapshot.data!.docs
                                                    .elementAt(index)
                                                    .get("sender")
                                            ? const BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                topLeft: Radius.circular(10),
                                              )
                                            : const BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                                topLeft: Radius.circular(10),
                                              )),
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                        "${snapshot.data!.docs.elementAt(index).get("mesaj")} "),
                                  ),
                                ),
                              );
                            } else {
                              return ListTile();
                            }
                          },
                        );
                      }
                    },
                  )),
                  Container(
                    height: 70,
                    decoration: BoxDecoration(color: Colors.deepPurple),
                    child: Row(
                      children: [
                        SizedBox(
                            width: size.width * 0.85,
                            child: InputField(controller: t1, hint: "message")),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () async {
                                  if (t1.text != "" &&
                                      t1.text != " " &&
                                      t1.text != "\t") {
                                    await _ref.add({
                                      "sender": widget.userId,
                                      "mesaj": t1.text.toString(),
                                      "date": DateTime.now()
                                    });
                                    t1.text = "";
                                  }
                                },
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                )))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
