part of './corte_interactivo_cubit.dart';

abstract class CorteInteractivoState extends Equatable {
  const CorteInteractivoState();

  @override
  List<Object> get props => [];
}

class CorteInteractivoInitial extends CorteInteractivoState {}

class CorteInteractivoLoading extends CorteInteractivoState {}

class CorteInteractivoReady extends CorteInteractivoState {
  final ui.Image image;
  final Uint8List bytes;

  const CorteInteractivoReady({
    required this.image,
    required this.bytes,
  });

  @override
  List<Object> get props => [image, bytes];
}

class CorteInteractivoError extends CorteInteractivoState {
  final String message;

  const CorteInteractivoError({required this.message});

  @override
  List<Object> get props => [message];
}
