import 'package:cloud_firestore/cloud_firestore.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String userId, {String? name, String? email}) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set({'name': name, 'email': email});
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<void> updateUser(String userId, {String? name, String? email}) async {
    await _firestore.collection('users').doc(userId).update(
      {'name': name, 'email': email},
    );
  }

  Future<String?> getUserName(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('users').doc(userId).get();
    return doc.exists ? doc.data()!['name'] as String? : null;
  }

  Stream<String?> getUserNameStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
        (DocumentSnapshot<Map<String, dynamic>> doc) =>
            doc.exists ? doc.data()!['name'] as String? : null);
  }
}
