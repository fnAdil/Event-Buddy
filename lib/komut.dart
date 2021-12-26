import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class komut {
  final _instance = FirebaseFirestore.instance;

  //verilen kullanıcı adı ile user oluşturma

  //  Future<void async > addWithUsernameasync {
  //    _instance.collection("konserler").doc(user_id).set({
  //             "name": "john",
  //             "age": 50,
  //             "email": "example@example.com",
  //             "address": {"street": "street 24", "city": "new york"}
  //           }).then((_) {
  //             print("success!");
  //           });

  //  }

  // rastgele kullanıcı adı ile user oluşturma

  //  Future<void async > addWithRandomUsernameasync {
  //    _instance.collection("users").add(
  // {
  //   "name" : "john",
  //   "age" : 50,
  //   "email" : "example@example.com",
  //   "address" : {
  //     "street" : "street 24",
  //     "city" : "new york"
  //   }
  // }).then((value){
  //   print(value.id);
  // });

  //  }

  //var olan kullanıcıya yeni özellik ekleme
  //set merge:true kullanıcı varsa günceller yoksa oluşturur
  //update sadece var olan kullanıcıları günceller veri yoksa işlem yapmaz

  // _instance.collection("konserler").doc(firebaseUser).set({
  //   "username": "userX",
  // }, SetOptions(merge: true)).then((_) {
  //   print("success!");
  // });

  //var olan kullanıcının bir özelliğini güncelleme

  // _instance.collection("konserler")
  //               .doc(firebaseUser)
  //               .update({"email": "example@test.com"}).then((_) {
  //             print("success!");
  //           });

  //var olan kullanıcının özelliğini güncellerken yeni özellik de eklenebilir

  // _instance.collection("konserler")
  //               .doc(firebaseUser)
  //               .update({"age": 60, "familyName": "Haddad"}).then((_) {
  //             print("success!");
  //           });

  //composit attribute güncelleme

  // _instance.collection("konserler").doc(firebaseUser).update({
  //           "age": 60,
  //           "familyName": "Haddad",
  //           "address.street": "street 50",
  //           "address.country": "USA"
  //         }).then((_) {
  //           print("success!");
  //         });

  //koleksiyon içinde koleksiyon oluşturma
// _instance.collection("konserler").add({
//               "name": "john",
//               "age": 50,
//               "email": "example@example.com",
//               "address": {"street": "street 24", "city": "new york"}
//             }).then((value) {
//               print(value.id);
//               _instance
//                   .collection("konserler")
//                   .doc(value.id)
//                   .collection("pets")
//                   .add({"petName": "blacky", "petType": "dog", "petAge": 1});
//             });

//veri silme
// _instance.collection("konserler")
//                 .doc(firebaseUser)
//                 .delete()
//                 .then((_) {
//               print("success!");
//             });

//var olan bir kullanıcının bir attributesini silme
// _instance.collection("konserler")
//                 .doc(firebaseUser)
//                 .update({"age": FieldValue.delete()}).then((_) {
//               print("success!");
//             });

}
