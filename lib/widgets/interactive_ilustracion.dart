import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/corte_interactivo/corte_interactivo_cubit.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/models/vista_cerebro.dart';
import 'package:neuroanatomy/painters/segmento_painter.dart';
import 'package:neuroanatomy/painters/vista_painter.dart';

class InteractiveIlustracion extends StatelessWidget {
  final CorteCerebro corteCerebro;
  final Function(SegmentoCerebro estructura)? onEstructuraTap;
  final Function(VistaCerebro vista)? onVistaTap;
  final bool showVistas;
  final List<SegmentoCerebro> highlightedSegmentos;

  const InteractiveIlustracion({
    super.key,
    required this.corteCerebro,
    this.onEstructuraTap,
    this.onVistaTap,
    this.highlightedSegmentos = const [],
    this.showVistas = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CorteInteractivoCubit>(
        create: (context) =>
            CorteInteractivoCubit(corte: corteCerebro)..getImages(),
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
            return LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  Image.memory(
                    readyState.currentImage.bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: false,
                    filterQuality: FilterQuality.high,
                  ),
                  ...corteCerebro.segmentos.map((segmento) {
                    return GestureDetector(
                        child: CustomPaint(
                          size: Size(
                            width,
                            width *
                                (readyState.currentImage.image.height /
                                    readyState.currentImage.image.width),
                          ),
                          painter: SegmentoPainter(
                            segmento: segmento.path,
                            isHighlighted:
                                highlightedSegmentos.contains(segmento),
                            cerebroSize: Size(
                              readyState.currentImage.image.width.toDouble(),
                              readyState.currentImage.image.height.toDouble(),
                            ),
                            highlightColor: Colors.green.withOpacity(0.5),
                          ),
                        ),
                        onTap: () {
                          onEstructuraTap?.call(segmento);
                        });
                  }).toList(),
                  if (showVistas)
                    ...corteCerebro.vistas.map((vista) {
                      return GestureDetector(
                        child: CustomPaint(
                          size: Size(
                            width,
                            width *
                                (readyState.currentImage.image.height /
                                    readyState.currentImage.image.width),
                          ),
                          painter: VistaPainter(
                            cerebroSize: Size(
                              readyState.currentImage.image.width.toDouble(),
                              readyState.currentImage.image.height.toDouble(),
                            ),
                            vista: vista.path,
                          ),
                        ),
                        onTap: () {
                          onVistaTap?.call(vista);
                        },
                      );
                    }),
                  if (readyState.alternativeImages.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.visibility,
                        ),
                        onPressed: () {
                          context.read<CorteInteractivoCubit>().toggleImage();
                        },
                      ),
                    ),
                ],
              );
            });
          },
        ));
  }
}
