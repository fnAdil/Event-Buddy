/*
    bu sayfa bir önceki sayfandan tarih ve şehir bilgilerini alır ve o zaman ve şehirdeki etkinlikleri
    veritabanından alarak listeler.
    her etkinlik için detayına yönlendirme yapar.
 */
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/models/Concert.dart';
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
    super.initState();
  }

  final _instance = FirebaseFirestore.instance; //veritabanı erişimi
  bool isLoading = false; //yüklenme kontrolü
  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd-MM-yyy').format(widget.date); //tarih formatlama
    return Scaffold(
      //başlık
      appBar: AppBar(
        title: const Text("Etkinlikler"),
        centerTitle: true,
      ),
      body: Stack(children: <Widget>[
        const Background(),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
            child: StreamBuilder<QuerySnapshot>(
              //konserlere erişim
              stream: _instance
                  .collection('konserler')
                  .where("tarih", isEqualTo: widget.date)
                  .where("şehir", isEqualTo: widget.city)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  //veri gelmemiş ise yükleniyor işareti
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                //veri var ise listeler
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              "${doc.get("konser_adı")[0].toString().toUpperCase()} "),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(formattedDate),
                        ),
                        subtitle: Text("${doc.get("şehir")}"),
                        title: Text("${doc.get("konser_adı")} "),

                        //seçilen konserin detayına yönlendirme
                        onTap: () {
                          Concert concert = Concert(
                              doc.id,
                              doc.get("konser_adı"),
                              doc.get("şehir"),
                              doc.get("tarih").toString());
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
}
