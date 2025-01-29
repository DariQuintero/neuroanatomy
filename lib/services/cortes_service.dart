import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';

class CortesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CortesService();

  Future<List<CorteCerebro>> getCortes() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('cortes').get();
    // for each document in the querySnapshot get segmentos
    final List<Map<String, dynamic>> cortesJson = [];
    final List<Map<String, dynamic>> vistasJson = [];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in querySnapshot.docs) {
      final corteJson = doc.data();
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('cortes')
          .doc(doc.id)
          .collection('segmentos')
          .get();
      // add segmentos to corteJson
      final List<Map<String, dynamic>> segmentosJson = [];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        segmentosJson.add(doc.data());
      }

      final QuerySnapshot<Map<String, dynamic>> querySnapshotVistas =
          await _firestore
              .collection('cortes')
              .doc(doc.id)
              .collection('vistas')
              .get();
      // add segmentos to corteJson
      final List<Map<String, dynamic>> vistasJson = [];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshotVistas.docs) {
        vistasJson.add(doc.data());
      }

      corteJson['segmentos'] = segmentosJson;
      corteJson['vistas'] = vistasJson;
      cortesJson.add(corteJson);
    }

    return cortesJson.map((e) => CorteCerebro.fromJson(e)).toList();
  }
}
