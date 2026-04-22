import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 SIMPAN / UPDATE USER DARI FIREBASE AUTH
  static Future<void> saveUser(User user) async {
    final userId = user.uid;

    await _db.collection('users').doc(userId).set({
      // DATA AUTH
      "uid": user.uid,
      "email": user.email,

      // PROFILE DASAR
      "nama": user.displayName ?? "User Baru",

      // DATA APLIKASI
      "avatar": "default",
      "theme": "light",
      "points": 0,
      "streak": 0,
      "lastMoodDate": "",

      // TIMESTAMP
      "createdAt": FieldValue.serverTimestamp(),
      "lastLogin": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}