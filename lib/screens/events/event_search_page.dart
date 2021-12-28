// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/models/Concert.dart';
import 'package:firebasedemo/screens/events/Events.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'event_detail.dart';

class EventSearch extends StatefulWidget {
  const EventSearch({
    Key? key,
    required this.city,
    required this.date,
  }) : super(key: key);
  final String city;
  final DateTime date;

  @override
  _EventSearchState createState() => _EventSearchState();
}

class _EventSearchState extends State<EventSearch> {
  @override
  void initState() {
    print(widget.date);
    super.initState();
  }

  final _instance = FirebaseFirestore.instance;
  final _userInstance = FirebaseAuth.instance;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final f = new DateFormat('yyyy-MM-dd hh:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text("Etkinlikler"),
        centerTitle: true,
      ),
      body: Stack(children: <Widget>[
        const Background(),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: _instance
                  .collection('konserler')
                  .where("tarih", isEqualTo: widget.date)
                  .where("şehir", isEqualTo: widget.city)
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
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                                "${doc.get("konser_adı")[0].toString().toUpperCase()} "),
                          ),
                          trailing: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text("date"),
                          ),
                          subtitle: Text("${doc.get("şehir")}"),
                          title: Text("${doc.get("konser_adı")} "),
                          onTap: () {
                            Concert concert = Concert(
                                doc.id,
                                doc.get("konser_adı"),
                                doc.get("şehir"),
                                doc.get("tarih"));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventDetail(
                                          concert: concert,
                                        )));

                            setState(() {});
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
            children: [
              const CircularProgressIndicator(),
              const Text("Yükleniyor...")
            ],
          ),
        ),
      ),
    );
  }
}
