import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/models/diagrama.dart';
import 'package:neuroanatomy/services/diagramas_service.dart';

part 'diagramas_state.dart';

class DiagramasCubit extends Cubit<DiagramasState> {
  final DiagramaType type;
  final DiagramasService _diagramasService;

  DiagramasCubit(
    this._diagramasService, {
    required this.type,
  }) : super(DiagramasInitial());

  Future<void> getDiagramas() async {
    emit(DiagramasLoading());
    try {
      final diagramas = await _diagramasService.getDiagramas(type);
      emit(DiagramasLoaded(diagramas: diagramas));
    } catch (e) {
      print(e);
      emit(DiagramasError(message: e.toString()));
    }
  }
}
