import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroanatomy/models/note.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId;
  NotesService({required this.userId});

  Future<void> createNote(Note note) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(note.structureId)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson());
  }

  Future<void> deleteNoteById(String structureId, String noteId) async {
    // await _firestore.collection('notes').doc(noteId).delete();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  Future<void> updateNoteById(String noteId, Note note) async {
    // await _firestore.collection('notes').doc(noteId).update(note.toJson());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(note.structureId)
        .collection('notes')
        .doc(noteId)
        .update(note.toJson());
  }

  Future<Note?> getNoteById(String structureId, String noteId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .doc(noteId)
        .get();
    return doc.exists ? Note.fromJson(doc.data()!) : null;
  }

  Future<List<Note>> getNotes(String structureId) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .get();
    return querySnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data()!;
      data['id'] = doc.id;
      return Note.fromJson(data);
    }).toList();
  }

  Stream<List<Note>> getNotesStream(String structureId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('structures')
        .doc(structureId)
        .collection('notes')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> querySnapshot) =>
            querySnapshot.docs
                .map((DocumentSnapshot<Map<String, dynamic>> doc) {
              final Map<String, dynamic> data = doc.data()!;
              data['id'] = doc.id;
              return Note.fromJson(data);
            }).toList());
  }
}
