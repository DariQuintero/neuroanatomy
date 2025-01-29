part of 'diagramas_cubit.dart';

abstract class DiagramasState extends Equatable {
  const DiagramasState();

  @override
  List<Object> get props => [];
}

class DiagramasInitial extends DiagramasState {}

class DiagramasLoading extends DiagramasState {}

class DiagramasLoaded extends DiagramasState {
  final List<Diagrama> diagramas;

  const DiagramasLoaded({required this.diagramas});

  @override
  List<Object> get props => [diagramas];
}

class DiagramasError extends DiagramasState {
  final String message;

  const DiagramasError({required this.message});

  @override
  List<Object> get props => [message];
}
