// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasedemo/models/Concert.dart';
import 'package:firebasedemo/screens/events/Events.dart';
import 'package:firebasedemo/static.dart';
import 'package:firebasedemo/static.dart';
import 'package:firebasedemo/static.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({Key? key, required this.concert}) : super(key: key);
  final Concert concert;

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  final _instance = FirebaseFirestore.instance;

  late CollectionReference _ref;

  void initState() {
    _ref = _instance
        .collection("konserler")
        .doc(widget.concert.id)
        .collection("katılımcılar");

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isError = false;
    var selectedDate = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyy').format(selectedDate);
    bool isSelf =
        false; //katılımcılar listelenirken kullanıcının kendisinin listelenmesini engellemek için

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.concert.id),
          Text(widget.concert.name),
          Text(widget.concert.city),
          Text(widget.concert.date),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: _instance
                .collection('konserler/${widget.concert.id}/katılımcılar')
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
                    print(doc.get("id") + "----.");
                    if (doc.get("id") == Static.user.id) {
                      isSelf = false;
                    } else {
                      isSelf = true;
                    }
                    return isSelf
                        ? Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text("${doc.get("name")} "),
                                  leading: CircleAvatar(
                                    foregroundImage: AssetImage(
                                      "assets/images/pp.png",
                                    ),
                                  ),
                                  trailing: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: TextButton(
                                      child: Text("İstek Gönder"),
                                      onPressed: () async {
                                        LoadingDialog();
                                        await _instance
                                            .collection("users")
                                            .doc(doc.get("id"))
                                            .collection("istekler")
                                            .get()
                                            .then((value) => {
                                                  value.docs.forEach((element) {
                                                    //eğer kişiye istek göndermişsek hata verir
                                                    if (element.get(
                                                                "konser_id") ==
                                                            widget.concert.id &&
                                                        element.get(
                                                                "sender_id") ==
                                                            Static.user.id) {
                                                      isError = true;
                                                      Navigator.pop(context);
                                                      ErrorDialog(
                                                          "Bu kişiye daha önce istek gönderdiniz!");
                                                      //eğer kişi bize göndermişse hata verir
                                                    } else {
                                                      isError = false;
                                                    }
                                                  })
                                                })
                                            .whenComplete(() async => {
                                                  await _instance
                                                      .collection("users")
                                                      .doc(Static.user.id)
                                                      .collection("istekler")
                                                      .get()
                                                      .then((value) => {
                                                            value.docs.forEach(
                                                                (element) {
                                                              //eğer kişiye istek göndermişsek hata verir
                                                              if (element.get(
                                                                          "konser_id") ==
                                                                      widget
                                                                          .concert
                                                                          .id &&
                                                                  element.get(
                                                                          "sender_id") ==
                                                                      doc.get(
                                                                          "id")) {
                                                                isError = true;
                                                                Navigator.pop(
                                                                    context);
                                                                ErrorDialog(
                                                                    "Bu kişi daha önce size istek göndermiş!");
                                                                //eğer kişi bize göndermişse hata verir
                                                              } else {
                                                                isError = false;
                                                              }
                                                            })
                                                          })
                                                })
                                            .whenComplete(() async => {
                                                  if (!isError)
                                                    {
                                                      await _instance
                                                          .collection("users")
                                                          .doc(doc.get("id"))
                                                          .collection(
                                                              "istekler")
                                                          .add({
                                                        "konser_ad":
                                                            widget.concert.name,
                                                        "konser_id":
                                                            widget.concert.id,
                                                        "name": (Static
                                                                .user.name
                                                                .toString() +
                                                            " " +
                                                            Static.user.lastname
                                                                .toString()),
                                                        "sender_id":
                                                            Static.user.id,
                                                        "tarih": formattedDate
                                                            .replaceAll(
                                                                "-", "."),
                                                        "şehir":
                                                            widget.concert.city,
                                                      }).whenComplete(() => {
                                                                print(
                                                                    formattedDate),
                                                                Navigator.pop(
                                                                    context),
                                                              })
                                                    }
                                                });

                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container();
                  }).toList(),
                );
            },
          )),
        ],
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
}
