part of './cortes_cubit.dart';

abstract class CortesState extends Equatable {
  const CortesState();

  @override
  List<Object?> get props => [];
}

class CortesInitial extends CortesState {}

class CortesLoading extends CortesState {}

class CortesReady extends CortesState {
  final List<CorteCerebro> cortes;
  final CorteCerebro selectedCorte;
  final SegmentoCerebro? selectedSegmento;
  final bool isShowingVistas;
  final ImageMode imageMode;

  const CortesReady({
    required this.cortes,
    required this.selectedCorte,
    this.selectedSegmento,
    this.isShowingVistas = false,
    this.imageMode = ImageMode.real,
  });

  @override
  List<Object?> get props =>
      [cortes, selectedCorte, selectedSegmento, isShowingVistas, imageMode];
}

class CortesError extends CortesState {
  final String message;

  const CortesError({required this.message});

  @override
  List<Object> get props => [message];
}
