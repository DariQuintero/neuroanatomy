import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroanatomy/models/activity.dart';
import 'package:neuroanatomy/models/note.dart';

class ActivitiesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId;
  final String noteId;
  final String structureId;
  ActivitiesService({
    required this.userId,
    required this.noteId,
    required this.structureId,
  });

  Future<void> createActivity(Activity activity) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .doc(noteId)
        .collection('activities')
        .add(activity.toJson());
  }

  Future<Activity?> getActivityById(String activityId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .doc(noteId)
        .collection('activities')
        .doc(activityId)
        .get();
    return doc.exists ? Activity.fromJson(doc.data()!) : null;
  }

  Future<Activity?> getActivityByType(ActivityType type) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .doc(noteId)
        .collection('activities')
        .where('type', isEqualTo: type.index)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return Activity.fromJson(doc.data());
    }
    return null;
  }
}
