import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/corte_interactivo/corte_interactivo_cubit.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/painters/segmento_painter.dart';

class InteractiveIlustracion extends StatefulWidget {
  final CorteCerebro corteCerebro;
  final Function(SegmentoCerebro estructura)? onEstructuraTap;
  final bool showCortes;
  final List<SegmentoCerebro> highlightedEstructuras;

  const InteractiveIlustracion({
    super.key,
    required this.corteCerebro,
    this.onEstructuraTap,
    this.highlightedEstructuras = const [],
    this.showCortes = false,
  });

  @override
  State<InteractiveIlustracion> createState() => _InteractiveIlustracionState();
}

class _InteractiveIlustracionState extends State<InteractiveIlustracion> {
  bool imageLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CorteInteractivoCubit>(
        create: (context) =>
            CorteInteractivoCubit(corte: widget.corteCerebro)..getImage(),
        child: BlocBuilder<CorteInteractivoCubit, CorteInteractivoState>(
          builder: (context, state) {
            if (state is CorteInteractivoLoading ||
                state is CorteInteractivoInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CorteInteractivoError) {
              return Center(
                child: Text(state.message),
              );
            }
            final readyState = (state as CorteInteractivoReady);
            return SizedBox(
              width: readyState.image.width.toDouble(),
              height: readyState.image.height.toDouble(),
              child: Stack(
                children: [
                  // render image
                  Image.memory(
                    readyState.bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  ),
                  ...widget.corteCerebro.segmentos.map((segmento) {
                    return GestureDetector(
                        child: CustomPaint(
                          size: Size(
                            readyState.image.width.toDouble(),
                            readyState.image.height.toDouble(),
                          ),
                          painter: SegmentoPainter(
                            segmento: segmento.path,
                            isHighlighted: widget.highlightedEstructuras
                                .contains(segmento),
                            cerebroSize: Size(
                              readyState.image.width.toDouble(),
                              readyState.image.height.toDouble(),
                            ),
                          ),
                        ),
                        onTap: () {
                          widget.onEstructuraTap?.call(segmento);
                        });
                  }).toList(),
                  // if (showCortes)
                  //   ...ilustracion.cortes.map((corte) {
                  //     return GestureDetector(
                  //       child: CustomPaint(
                  //         size: Size(width, width * aspectRatio),
                  //         painter: corte.painter,
                  //       ),
                  //       onTap: () {
                  //         onCorteTap?.call(corte);
                  //       },
                  //     );
                  //   }),
                ],
              ),
            );
          },
        ));
  }
}
