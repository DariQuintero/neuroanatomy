part of './corte_interactivo_cubit.dart';

abstract class CorteInteractivoState extends Equatable {
  const CorteInteractivoState();

  @override
  List<Object> get props => [];
}

class CorteInteractivoInitial extends CorteInteractivoState {}

class CorteInteractivoLoading extends CorteInteractivoState {}

class CorteInteractivoReady extends CorteInteractivoState {
  final DisplayableImage currentImage;
  final List<DisplayableImage> alternativeImages;

  const CorteInteractivoReady({
    required this.currentImage,
    this.alternativeImages = const [],
  });

  @override
  List<Object> get props => [currentImage, alternativeImages];
}

class CorteInteractivoError extends CorteInteractivoState {
  final String message;

  const CorteInteractivoError({required this.message});

  @override
  List<Object> get props => [message];
}
