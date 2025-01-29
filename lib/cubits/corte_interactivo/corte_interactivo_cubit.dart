import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/displayable_image.dart';
import 'package:path_provider/path_provider.dart';

part './corte_interactivo_state.dart';

class CorteInteractivoCubit extends Cubit<CorteInteractivoState> {
  final CorteCerebro corte;

  CorteInteractivoCubit({required this.corte})
      : super(CorteInteractivoInitial());

  Future<void> getImages() async {
    emit(CorteInteractivoLoading());
    try {
      final cachedImage = await _getImageFromCache();
      if (cachedImage != null) {
        final decodedImage = await decodeImageFromList(cachedImage);
        if (isClosed) return;
        emit(
          CorteInteractivoReady(
            currentImage:
                DisplayableImage(image: decodedImage, bytes: cachedImage),
          ),
        );
        _getAlternativeImages();
        return;
      }
      final data = await NetworkAssetBundle(Uri.parse(corte.realImage))
          .load(corte.realImage);
      final bytes = data.buffer.asUint8List();
      _saveImageInCache(bytes);
      final decodedImage = await decodeImageFromList(bytes);
      if (isClosed) return;
      emit(CorteInteractivoReady(
        currentImage: DisplayableImage(image: decodedImage, bytes: bytes),
      ));
      _getAlternativeImages();
    } catch (e) {
      if (isClosed) return;
      emit(CorteInteractivoError(message: e.toString()));
    }
  }

  Future<void> toggleImage() async {
    if (state is! CorteInteractivoReady) return;
    final currentState = state as CorteInteractivoReady;
    if (currentState.alternativeImages.isEmpty) return;
    final nextImage = currentState.alternativeImages.last;
    final nextAlternativeImages = currentState.alternativeImages
      ..removeAt(0)
      ..add(currentState.currentImage);
    emit(
      CorteInteractivoReady(
        currentImage: nextImage,
        alternativeImages: nextAlternativeImages,
      ),
    );
  }

  Future<void> _getAlternativeImages() async {
    final alternativeUrls = [];
    if (corte.aquarelaImage != null) {
      alternativeUrls.add(corte.aquarelaImage);
    }

    for (final alternativeUlr in alternativeUrls) {
      final data = await NetworkAssetBundle(Uri.parse(alternativeUlr))
          .load(alternativeUlr);
      final bytes = data.buffer.asUint8List();
      final decodedImage = await decodeImageFromList(bytes);
      if (isClosed) return;
      if (state is! CorteInteractivoReady) return;
      final currentState = state as CorteInteractivoReady;
      emit(
        CorteInteractivoReady(
          currentImage: currentState.currentImage,
          alternativeImages: [
            ...currentState.alternativeImages,
            DisplayableImage(image: decodedImage, bytes: bytes),
          ],
        ),
      );
    }
  }

  Future<File> _saveImageInCache(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/${corte.id}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<Uint8List?> _getImageFromCache() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/${corte.id}.png');
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }
}
