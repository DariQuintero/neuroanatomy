import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/cortes_cubit.dart/cortes_cubit.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/home_page/widgets/estructura_details_panel.dart';
import 'package:neuroanatomy/services/cortes_service.dart';
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

    return Scaffold(
      body: BlocProvider<CortesCubit>(
        create: (context) => CortesCubit(CortesService())..getCortes(),
        child: BlocBuilder<CortesCubit, CortesState>(
          builder: (context, state) {
            if (state is CortesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CortesError) {
              return Center(
                child: Text(state.message),
              );
            }

            final cortes = (state as CortesReady).cortes;
            if (cortes.isEmpty) {
              return const Center(
                child: Text('No hay cortes'),
              );
            }

            return Stack(
              children: [
                _buildBody(context, state),
                _buildFab(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Positioned(
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
    );
  }

  Widget _buildBody(BuildContext context, CortesReady cortesState) {
    final size = context.mediaQuery.size;
    final panelHeightOpen = size.height - context.mediaQuery.padding.top;
    return SlidingUpPanel(
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
      body: SizedBox(
        child: InteractiveIlustracion(
          corteCerebro: cortesState.selectedCorte,
          onEstructuraTap: (id) {
            context.read<CortesCubit>().selectSegmento(id);
            panelController.open();
          },
        ),
      ),
      panelBuilder: (sc) {
        final segmento = cortesState.selectedSegmento;
        return _panel(sc, segmento, context);
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
        context.read<CortesCubit>().selectSegmento(null);
      },
    );
  }

  Widget _panel(
      ScrollController sc, SegmentoCerebro? segmento, BuildContext context) {
    if (segmento == null) {
      return const SizedBox.shrink();
    }
    return EstructuraDetailsPanel(
      segmento: segmento,
      scrollController: sc,
    );
  }
}
