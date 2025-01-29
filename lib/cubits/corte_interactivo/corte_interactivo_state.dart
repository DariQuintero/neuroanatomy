part of './corte_interactivo_cubit.dart';

abstract class CorteInteractivoState extends Equatable {
  const CorteInteractivoState();

  @override
  List<Object> get props => [];
}

class CorteInteractivoInitial extends CorteInteractivoState {}

class CorteInteractivoLoading extends CorteInteractivoState {}

class CorteInteractivoReady extends CorteInteractivoState {
  final List<DisplayableImage> images;

  const CorteInteractivoReady({
    required this.images,
  });

  @override
  List<Object> get props => [images];

  DisplayableImage? imageForMode(ImageMode mode) {
    return images.firstWhereOrNull((element) => element.mode == mode);
  }
}

class CorteInteractivoError extends CorteInteractivoState {
  final String message;

  const CorteInteractivoError({required this.message});

  @override
  List<Object> get props => [message];
}
