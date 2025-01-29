import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/cortes_cubit.dart/cortes_cubit.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/widgets/interactive_ilustracion.dart';

class OtherCortesGrid extends StatelessWidget {
  final SegmentoCerebro currentSegmento;
  final List<CorteCerebro> allCortes;
  const OtherCortesGrid(
      {super.key, required this.currentSegmento, required this.allCortes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: allCortes.length,
      itemBuilder: (context, index) {
        final corte = allCortes[index];
        final segmento = corte.segmentos.firstWhere(
            (element) => element.id == currentSegmento.id,
            orElse: () => currentSegmento);
        final size = context.mediaQuery.size.width * 0.4;
        return Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.theme.colorScheme.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: GestureDetector(
            onTap: () {
              context.read<CortesCubit>().selectCorte(corte);
            },
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: InteractiveIlustracion(
                  key: ValueKey(corte.id),
                  corteCerebro: corte,
                  highlightedSegmentos: [segmento],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
