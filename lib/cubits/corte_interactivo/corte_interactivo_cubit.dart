import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:path_provider/path_provider.dart';

part './corte_interactivo_state.dart';

class CorteInteractivoCubit extends Cubit<CorteInteractivoState> {
  final CorteCerebro corte;

  CorteInteractivoCubit({required this.corte})
      : super(CorteInteractivoInitial());

  Future<void> getImage() async {
    emit(CorteInteractivoLoading());
    try {
      final cachedImage = await _getImageFromCache();
      if (cachedImage != null) {
        final decodedImage = await decodeImageFromList(cachedImage);
        if (isClosed) return;
        emit(CorteInteractivoReady(image: decodedImage, bytes: cachedImage));
        return;
      }
      final data = await NetworkAssetBundle(Uri.parse(corte.realImage))
          .load(corte.realImage);
      final bytes = data.buffer.asUint8List();
      _saveImageInCache(bytes);
      final decodedImage = await decodeImageFromList(bytes);
      if (isClosed) return;
      emit(CorteInteractivoReady(image: decodedImage, bytes: bytes));
    } catch (e) {
      if (isClosed) return;
      emit(CorteInteractivoError(message: e.toString()));
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
