import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/fcm_credentials.dart'; // Just to check it exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final snap = await FirebaseFirestore.instance.collection('payments').limit(5).get();
  for (var doc in snap.docs) {
    print('PAYMENT_DOC: ${doc.id} => ${doc.data()}');
  }
}
