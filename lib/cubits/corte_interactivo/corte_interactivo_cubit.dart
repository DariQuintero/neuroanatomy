import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
      final images = (await Future.wait(
        ImageMode.values.map((mode) async {
          final cachedImage = await _getImageFromCache(mode, corte.id);
          if (cachedImage != null) {
            final decodedImage = await decodeImageFromList(cachedImage);
            return DisplayableImage(
                image: decodedImage, bytes: cachedImage, mode: mode);
          }
          final imageUrl = corte.imageUrlForMode(mode);
          if (imageUrl == null) return null;
          final data =
              await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
          final bytes = data.buffer.asUint8List();
          final decodedImage = await decodeImageFromList(bytes);
          _saveImageInCache(bytes, mode, corte.id);
          return DisplayableImage(
              image: decodedImage, bytes: bytes, mode: mode);
        }),
      ))
          .whereType<DisplayableImage>()
          .toList();
      if (isClosed) return;

      emit(CorteInteractivoReady(
        images: images,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(CorteInteractivoError(message: e.toString()));
    }
  }

  Future<File> _saveImageInCache(
      Uint8List bytes, ImageMode mode, String corteId) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/${mode.name}_${corteId}_v1.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<Uint8List?> _getImageFromCache(ImageMode mode, String corteId) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/${mode.name}_${corteId}_v1.png');
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }
}
