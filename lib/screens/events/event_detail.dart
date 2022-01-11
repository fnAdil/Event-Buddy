/*
  Bu sayfa konsere dair detaylı bilginin yer aldığı yerdir.
  Burada konerin adı, tarihi gibi bilgiler yer almakta ve konsere katılan kullanıcılar listelenmektedir.
  Bu sayfadan seçilen etkinliğe katılım sağlayabilir ve katılan kullanıcılara istek atabilirsiniz.

  Fakat kullanıcılar her konsere 1 kez katılabilir, tekrar katılmak isterse uyarı mesajı alırlar.
  Aynı şekilde kullanıcılar her kişiye 1 kez istek atabilir, diğer kullanıcı zaten istek atmış ise istek atamaz
  ve zaten eşleştiği bir kullanıcıya istek atamaz. Bu durumlarda gerekli uyarı mesajları alır.

 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/models/Concert.dart';
import 'package:firebasedemo/static.dart';
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

//sayfanın başlangıcında konsere katılan kişilerin listesi veritabanından alınır.
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isError = false; //hata oluşursa kontrol etmek için
    bool isMember =
        false; //kullanıcının kendisinin katılımcılar arasında listelenmesini engeller
    var selectedDate = DateTime.now(); //zaman bilgisi için
    String formattedDate = DateFormat('dd-MM-yyy')
        .format(selectedDate); //zaman bilgisi istenilen forma sokulur.
    bool isSelf =
        false; //katılımcılar listelenirken kullanıcının kendisinin listelenmesini engellemek için
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.concert.name),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Background(), //arkaplan fotoğrafı
          Column(
            children: [
              Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.concert.name, //konser adı
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.concert.city, //konserin şehri
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20)),
                        Text(formattedDate, //konserin tarihi
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20)),
                        TextButton(
                            onPressed: () {
                              konsereKatil(isMember); //konsere katılma butonu
                              setState(() {});
                            },
                            child: const Text(
                              "Katıl",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 20),
                            ))
                      ],
                    ),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.deepPurple, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                  ),
                  flex: 1),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          //Konsere katılanlar veritabanından çekilip listelenir
                          child: StreamBuilder<QuerySnapshot>(
                        stream: _instance
                            .collection(
                                'konserler/${widget.concert.id}/katılımcılar')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            //eğer henüz veritabanına bağlanamamışsa yükleniyor işareti çıkar
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            //veri gelmiş ise listelenir
                            return ListView(
                              children: snapshot.data!.docs.map((doc) {
                                print(doc.get("id") + "----.");
                                if (doc.get("id") == Static.user.id) {
                                  isSelf = true;
                                } else {
                                  isSelf = false;
                                }
                                //eğer katılımcılar arasındakişinin kendisi varsa listelenmez
                                return !(isSelf)
                                    ? Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                  "${doc.get("name")}"), //katılımcı ismi
                                              //profil fotoğrafı
                                              leading:
                                                  doc.get("profilePhoto") == ""
                                                      ? const CircleAvatar(
                                                          foregroundImage:
                                                              AssetImage(
                                                                  "assets/images/person.png"),
                                                        )
                                                      : CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(doc.get(
                                                                  "profilePhoto")),
                                                        ),
                                              trailing: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: TextButton(
                                                  child: const Text(
                                                      "İstek Gönder"), //istek butonu
                                                  onPressed: () async {
                                                    loadingDialog(); //yükleniyor işareti
                                                    istek(doc, isError,
                                                        formattedDate);
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
                          }
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//bu metod veritabanından kontrol işlemleri yapar eğer sorun yok ise mevcut kullanıcıyı istek gönderilen kişinin istekler listesine ekler
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
                  errorDialog(
                      "Bu kişiye daha önce istek gönderdiniz!"); //hata mesajı
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
                            errorDialog(
                                "Bu kişi daha önce size istek göndermiş!"); //hata mesajı
                          } else {}
                        })
                      })
            })
        .whenComplete(() async => {
              //eğer kişi ile zaten eşleşmişsek(mesajlarda var ise)
              await _instance
                  .collection("mesajlar")
                  .where("üyeler",
                      arrayContains: {Static.user.id.toString(), doc.get("id")})
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
                            errorDialog(
                                "Bu kişi ile zaten eşleştiniz!"), //hata mesajı
                          }
                      })
            })
        .whenComplete(() async => {
              //hata yok ise istek atılan kişinin istekler listesine eklenir
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
                    "profilePhoto": Static.user.profilePhoto
                  }).whenComplete(() => {
                            print(formattedDate),
                            Navigator.pop(context),
                          })
                }
            });
  }

//yükleniyor ekranı
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

  //hata mesaj ekranı
  Future<String?> errorDialog(String errorMessage) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Center(child: Text("Hata")),
        content: Container(
            padding: const EdgeInsets.all(8),
            height: 80,
            child: Center(
                child: Text(
              errorMessage,
            ))),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Center(child: Text('OK')),
          ),
        ],
      ),
    );
  }

  //konsere katıl butonu
  //mevcut konserin katılımcılar listesinde mevcut kullanıcıyı arar eğer yok ise ekler;
  //var ise uygun hata mesajını gösterir
  void konsereKatil(bool isMember) async {
    loadingDialog();
    await _instance
        .collection("konserler")
        .doc(widget.concert.id)
        .collection("katılımcılar")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                //eğer konsere katılmışsak hata verir
                if (element.get("id") == Static.user.id) {
                  isMember = true;
                  Navigator.pop(context);
                  errorDialog("Zaten bu konsere katıldınız!");
                }
              })
            })
        .whenComplete(() async {
      //eğer katılımcı değilsek ekler.
      if (!isMember) {
        await _instance
            .collection("konserler")
            .doc(widget.concert.id)
            .collection("katılımcılar")
            .add({
          "id": Static.user.id,
          "profilePhoto": Static.user.profilePhoto,
          "name": (Static.user.name.toString() +
              " " +
              Static.user.lastname.toString())
        });
        Navigator.pop(context);
      }
    });
  }
}
