import 'package:flutter/material.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/home_page/widgets/other_cortes_grid.dart';
import 'package:neuroanatomy/widgets/drag_indicator.dart';

class EstructuraDetailsPanel extends StatelessWidget {
  final ScrollController scrollController;
  final SegmentoCerebro segmento;
  final List<CorteCerebro> allCortes;
  const EstructuraDetailsPanel(
      {super.key,
      required this.scrollController,
      required this.segmento,
      required this.allCortes});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          controller: scrollController,
          children: [
            const SizedBox(height: 4.0),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [DragIndicator()],
            ),
            const SizedBox(height: 14.0),
            Text(
              segmento.nombre,
              style: context.theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.description,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Notas',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    elevation: 4.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton.small(
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 4.0,
                  child: Icon(
                    Icons.add,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            SizedBox(
                height: context.mediaQuery.size.height * 0.25,
                child: OtherCortesGrid(
                    allCortes: allCortes, currentSegmento: segmento)),
          ],
        ),
      ),
    );
  }
}
