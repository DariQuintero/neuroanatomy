import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroanatomy/models/diagrama.dart';

class DiagramasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DiagramasService();

  Future<List<Diagrama>> getDiagramas(DiagramaType type) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('diagramas')
        .where('type', isEqualTo: type.value)
        .get();

    final List<Diagrama> diagramas = [];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in querySnapshot.docs) {
      final diagramaJson = doc.data();

      diagramas.add(Diagrama.fromJson(diagramaJson));
    }

    return diagramas;
  }
}
