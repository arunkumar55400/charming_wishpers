import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataService {
  var _firestore = FirebaseFirestore.instance.collection('wishpers');

  getWispers() async {
    _firestore.get().then((value) {
      print(value.docs);
      
    });
  }
}
