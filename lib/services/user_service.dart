import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> ensureUserDocument(User user) async {
    final doc = users.doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'address': '',
        'payment': '',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserDoc() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return users.doc(uid).get();
  }
Future<bool> isAdmin(String uid) async {
  final doc = await users.doc(uid).get();
  if (!doc.exists) return false;

  final data = doc.data() as Map<String, dynamic>?;
  return (data?['isAdmin'] ?? false) == true;
}

}
