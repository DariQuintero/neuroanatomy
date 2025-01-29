import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';

part './corte_interactivo_state.dart';

class CorteInteractivoCubit extends Cubit<CorteInteractivoState> {
  final CorteCerebro corte;

  CorteInteractivoCubit({required this.corte})
      : super(CorteInteractivoInitial());

  Future<void> getImage() async {
    emit(CorteInteractivoLoading());
    try {
      final data = await NetworkAssetBundle(Uri.parse(corte.realImage))
          .load(corte.realImage);
      final bytes = data.buffer.asUint8List();
      final decodedImage = await decodeImageFromList(bytes);
      emit(CorteInteractivoReady(image: decodedImage, bytes: bytes));
    } catch (e) {
      emit(CorteInteractivoError(message: e.toString()));
    }
  }
}
