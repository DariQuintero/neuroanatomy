import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/ilustracion_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/home_page/widgets/estructura_details_panel.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/corte_de_charcot.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/giro_precentral.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/giro_temporal_superior.dart';
import 'package:neuroanatomy/widgets/interactive_ilustracion.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _initialFabHeight = 32.0;
  String? currentEstructuraId;
  bool showCortes = false;
  late PanelController panelController;
  double? _fabPadding;
  bool showFab = true;

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
    _fabPadding = _initialFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    // get the svg string from the assets
    final size = context.mediaQuery.size;
    final width = size.width;
    const aspectRatio = 0.752;
    final panelHeightOpen = size.height - context.mediaQuery.padding.top;
    IlustracionCerebro ilustracion = IlustracionCerebro(
      id: 'lateral_izquierdo',
      nombre: 'Corte transversal',
      realPath: 'assets/cerebro1/lateral_izquierdo/recortado.png',
      estructuras: [
        EstructuraCerebro(
          id: 'giro_precentral',
          nombre: 'Giro Precentral',
          painter: GiroPrecentral(
              highlight: currentEstructuraId == 'giro_precentral'),
        ),
        EstructuraCerebro(
          id: 'giro_temporal_superior',
          nombre: 'Giro Temporal Superior',
          painter: GiroTemporalSuperior(
              highlight: currentEstructuraId == 'giro_temporal_superior'),
        ),
      ],
      cortes: [
        CorteCerebro(
          id: 'corte_de_charcot',
          nombre: 'Corte de Chartcot',
          painter: CorteDeCharcot(),
          toIlustracionId: 'lateral_izquierdo',
        )
      ],
    );
    return Scaffold(
      backgroundColor: context.theme.colorScheme.secondary,
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: panelController,
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            snapPoint: 0.3,
            maxHeight: panelHeightOpen,
            minHeight: 0,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            body: Center(
                child: _buildIlustracion(
                    ilustracion, width, aspectRatio, context)),
            panelBuilder: (sc) {
              final estructura = ilustracion.estructuras
                  .firstWhereOrNull((e) => e.id == currentEstructuraId);
              return _panel(sc, estructura, context);
            },
            onPanelSlide: (position) {
              final currentTop = panelHeightOpen * position;
              final hideFab = position > 0.5;
              setState(() {
                _fabPadding = currentTop + _initialFabHeight;
                showFab = !hideFab;
              });
            },
            onPanelClosed: () {
              setState(() {
                currentEstructuraId = null;
              });
            },
          ),
          Positioned(
            right: 20.0,
            bottom: _fabPadding,
            child: AnimatedOpacity(
              opacity: showFab ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: context.theme.colorScheme.primary,
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc, EstructuraCerebro? estructura,
      BuildContext context) {
    if (estructura == null) {
      return const SizedBox();
    }
    return EstructuraDetailsPanel(scrollController: sc, estructura: estructura);
  }

  Widget _buildIlustracion(IlustracionCerebro ilustracion, double width,
      double aspectRatio, BuildContext context) {
    return InteractiveIlustracion(
      ilustracion: ilustracion,
      width: width,
      aspectRatio: aspectRatio,
      onEstructuraTap: (estructura) {
        if (currentEstructuraId == estructura.id) {
          setState(() {
            currentEstructuraId = null;
          });
          panelController.animatePanelToPosition(0,
              duration: const Duration(milliseconds: 200));
        } else {
          setState(() {
            currentEstructuraId = estructura.id;
          });
          panelController.show();
          panelController.animatePanelToSnapPoint(
            duration: const Duration(milliseconds: 200),
          );
        }
      },
    );
  }
}
