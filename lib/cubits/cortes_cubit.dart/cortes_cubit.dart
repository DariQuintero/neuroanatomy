import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/services/cortes_service.dart';

part './cortes_state.dart';

class CortesCubit extends Cubit<CortesState> {
  final CortesService _cortesService;

  CortesCubit(this._cortesService) : super(CortesInitial());

  Future<void> getCortes() async {
    emit(CortesLoading());
    try {
      final List<CorteCerebro> cortes = await _cortesService.getCortes();
      emit(CortesReady(cortes: cortes, selectedCorte: cortes.first));
    } catch (e) {
      emit(CortesError(message: e.toString()));
      rethrow;
    }
  }

  void selectCorte(CorteCerebro corte) {
    if (state is! CortesReady) return;
    final currentSelectedSegmento = (state as CortesReady).selectedSegmento;
    final segmentoInNewCorte = corte.segmentos.firstWhereOrNull(
      (s) => s.id == currentSelectedSegmento?.id,
    );
    emit(
      CortesReady(
        cortes: (state as CortesReady).cortes,
        selectedCorte: corte,
        selectedSegmento: segmentoInNewCorte,
        isShowingVistas: (state as CortesReady).isShowingVistas,
        imageMode: (state as CortesReady).imageMode,
      ),
    );
  }

  void selectCorteById(String id) {
    if (state is! CortesReady) return;
    final cortes = (state as CortesReady).cortes;
    final corte = cortes.firstWhereOrNull((c) => c.id == id);
    if (corte == null) return;
    selectCorte(corte);
  }

  void selectSegmento(SegmentoCerebro? segmento) {
    if (state is! CortesReady) return;
    emit(
      CortesReady(
        cortes: (state as CortesReady).cortes,
        selectedCorte: (state as CortesReady).selectedCorte,
        selectedSegmento: segmento,
        isShowingVistas: (state as CortesReady).isShowingVistas,
        imageMode: (state as CortesReady).imageMode,
      ),
    );
  }

  void selectSegmentoById(String id) {
    if (state is! CortesReady) return;
    final segmento = (state as CortesReady)
        .selectedCorte
        .segmentos
        .firstWhereOrNull((s) => s.id == id);
    if (segmento == null) return;
    selectSegmento(segmento);
  }

  void toggleShowingVistas() {
    if (state is! CortesReady) return;
    emit(
      CortesReady(
        cortes: (state as CortesReady).cortes,
        selectedCorte: (state as CortesReady).selectedCorte,
        selectedSegmento: (state as CortesReady).selectedSegmento,
        isShowingVistas: !(state as CortesReady).isShowingVistas,
        imageMode: (state as CortesReady).imageMode,
      ),
    );
  }

  void changeImageMode(ImageMode mode) {
    if (state is! CortesReady) return;
    emit(
      CortesReady(
        cortes: (state as CortesReady).cortes,
        selectedCorte: (state as CortesReady).selectedCorte,
        selectedSegmento: (state as CortesReady).selectedSegmento,
        isShowingVistas: (state as CortesReady).isShowingVistas,
        imageMode: mode,
      ),
    );
  }
}
