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
    bool isMatch =
        false; //katılımcılar listelenirken kullanıcının zaten eşleştiği kişilerin listelenmesini engellemek için
    bool isRequest =
        false; //katılımcılar listelenirken kullanıcının istek listesindeki kişilerin listelenmesini engellemek için
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.concert.name),
        centerTitle: true,
      ),
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
                    // doc.get("ref");
                    print(doc.get("id") + "----.");
                    //eğer katılımcılar arasındakişinin kendisi varsa listelenmez

                    if (doc.get("id") == Static.user.id) {
                      isSelf = true;
                    } else {
                      isSelf = false;
                    }

                    return !(isSelf)
                        ? Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text("${doc.get("name")}"),
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
                                        istek(doc, isError, formattedDate);
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

  Future istek(QueryDocumentSnapshot<Object?> doc, bool isError,
      String formattedDate) async {
    await _instance
        .collection("users")
        .doc(doc.get("id"))
        .collection("istekler")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                //eğer kişiye istek göndermişsek hata verir
                if (element.get("konser_id") == widget.concert.id &&
                    element.get("sender_id") == Static.user.id) {
                  isError = true;
                  Navigator.pop(context);
                  ErrorDialog("Bu kişiye daha önce istek gönderdiniz!");
                } else {}
              })
            })
        .whenComplete(() async => {
              await _instance
                  .collection("users")
                  .doc(Static.user.id)
                  .collection("istekler")
                  .get()
                  .then((value) => {
                        value.docs.forEach((element) {
                          //eğer kişi bize istek göndermişse hata verir
                          if (element.get("konser_id") == widget.concert.id &&
                              element.get("sender_id") == doc.get("id")) {
                            isError = true;
                            Navigator.pop(context);
                            ErrorDialog(
                                "Bu kişi daha önce size istek göndermiş!");
                          } else {}
                        })
                      })
            })
        .whenComplete(() async => {
              await _instance
                  .collection("mesajlar")
                  .where("üyeler", arrayContains: Static.user.id.toString())
                  .where("konser_id", isEqualTo: widget.concert.id)
                  .get()
                  .then((value) => {
                        if (value.docs.isEmpty)
                          {print("boş------------------")}
                        else
                          {
                            print("bdolu------------------"),
                            isError = true,
                            Navigator.pop(context),
                            ErrorDialog("Bu kişi ile zaten eşleştiniz!"),
                          }
                      })
            })
        .whenComplete(() async => {
              if (!isError)
                {
                  await _instance
                      .collection("users")
                      .doc(doc.get("id"))
                      .collection("istekler")
                      .add({
                    "konser_ad": widget.concert.name,
                    "konser_id": widget.concert.id,
                    "name": (Static.user.name.toString() +
                        " " +
                        Static.user.lastname.toString()),
                    "sender_id": Static.user.id,
                    "tarih": formattedDate.replaceAll("-", "."),
                    "şehir": widget.concert.city,
                  }).whenComplete(() => {
                            print(formattedDate),
                            Navigator.pop(context),
                          })
                }
            });
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
