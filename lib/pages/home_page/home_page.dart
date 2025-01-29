import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/cubits/cortes_cubit.dart/cortes_cubit.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/diagrama.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/diagramas_page/diagramas_page.dart';
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
    return BlocProvider<CortesCubit>(
      create: (context) => CortesCubit(CortesService())..getCortes(),
      child: Scaffold(
        appBar: AppBar(
          title: const Image(
            image: AssetImage('assets/logo.png'),
            height: 40,
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          leading: PopupMenuButton<DiagramaType>(
            itemBuilder: (context) {
              return DiagramaType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Text(type.title),
                );
              }).toList();
            },
            onSelected: (value) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return DiagramasPage(type: value);
              }));
            },
          ),
        ),
        body: BlocConsumer<CortesCubit, CortesState>(
          listener: (context, state) {
            if (state is CortesReady) {
              if (!panelController.isAttached) return;
              final selectedSegmento = state.selectedSegmento;
              if (selectedSegmento != null) {
                panelController.open();
              } else {
                panelController.close();
              }
            }
          },
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
                _buildFab(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final state = context.read<CortesCubit>().state;
    if (state is! CortesReady) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: 20.0,
      bottom: _fabPadding,
      child: AnimatedOpacity(
        opacity: showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton(
          onPressed: () {
            context.read<CortesCubit>().toggleShowingVistas();
          },
          backgroundColor: state.isShowingVistas
              ? Colors.white
              : context.theme.colorScheme.primary,
          child: SizedBox(
            width: 24,
            child: SvgPicture.asset(
              'assets/icons/surgical.svg',
              colorFilter: ColorFilter.mode(
                state.isShowingVistas
                    ? context.theme.colorScheme.primary
                    : Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CortesReady cortesState) {
    final size = context.mediaQuery.size;
    final panelHeightOpen =
        (size.height * 0.5) - context.mediaQuery.padding.top;

    return SlidingUpPanel(
      controller: panelController,
      parallaxEnabled: true,
      parallaxOffset: 0.4,
      maxHeight: panelHeightOpen,
      minHeight: 0,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: context.mediaQuery.size.height * 0.2),
        child: Stack(
          children: [
            _buildNavigationButtons(cortesState, context),
            _buildInteractiveIlustration(cortesState, context),
          ],
        ),
      ),
      panelBuilder: (sc) {
        final segmento = cortesState.selectedSegmento;
        return _buildPanel(
          sc,
          segmento,
          cortesState.cortes,
          cortesState.selectedCorte,
          cortesState.imageMode,
          context,
        );
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

  Widget _buildIzquierdaButton(BuildContext context) {
    bool transparent = false;
    final state = context.read<CortesCubit>().state;
    if (state is! CortesReady) {
      transparent = true;
    }

    state as CortesReady;
    final currentCorte = state.selectedCorte;
    final izquierdaId = currentCorte.izquierdaId;
    if (izquierdaId == null) {
      transparent = true;
    }

    return IconButton(
      onPressed: () {
        final state = context.read<CortesCubit>().state;
        if (state is! CortesReady) {
          return;
        }
        final currentCorte = state.selectedCorte;
        final izquierdaId = currentCorte.izquierdaId;
        final corteTo = state.cortes.firstWhereOrNull(
          (corte) => corte.id == izquierdaId,
        );

        if (corteTo == null) {
          return;
        }

        context.read<CortesCubit>().selectCorte(corteTo);
      },
      icon: const Icon(Icons.arrow_back_ios),
      color: transparent ? Colors.transparent : null,
    );
  }

  Widget _buildDerechaButton(BuildContext context) {
    bool transparent = false;
    final state = context.read<CortesCubit>().state;
    if (state is! CortesReady) {
      transparent = true;
    }

    state as CortesReady;
    final currentCorte = state.selectedCorte;
    final derechaId = currentCorte.derechaId;
    if (derechaId == null) {
      transparent = true;
    }

    return IconButton(
      onPressed: () {
        final state = context.read<CortesCubit>().state;
        if (state is! CortesReady) {
          return;
        }
        final currentCorte = state.selectedCorte;
        final derechaId = currentCorte.derechaId;

        final corteTo = state.cortes.firstWhereOrNull(
          (corte) => corte.id == derechaId,
        );

        if (corteTo == null) {
          return;
        }

        context.read<CortesCubit>().selectCorte(corteTo);
      },
      icon: const Icon(Icons.arrow_forward_ios),
      color: transparent ? Colors.transparent : null,
    );
  }

  Widget _buildArribaButton(BuildContext context) {
    bool transparent = false;
    final state = context.read<CortesCubit>().state;
    if (state is! CortesReady) {
      transparent = true;
    }

    state as CortesReady;
    final currentCorte = state.selectedCorte;
    final arribaId = currentCorte.arribaId;
    if (arribaId == null) {
      transparent = true;
    }

    return IconButton(
      onPressed: () {
        final state = context.read<CortesCubit>().state;
        if (state is! CortesReady) {
          return;
        }
        final currentCorte = state.selectedCorte;
        final arribaId = currentCorte.arribaId;

        final corteTo = state.cortes.firstWhereOrNull(
          (corte) => corte.id == arribaId,
        );

        if (corteTo == null) {
          return;
        }

        context.read<CortesCubit>().selectCorte(corteTo);
      },
      icon: const Icon(Icons.arrow_upward),
      color: transparent ? Colors.transparent : null,
    );
  }

  Widget _buildAbajoButton(BuildContext context) {
    bool transparent = false;
    final state = context.read<CortesCubit>().state;
    if (state is! CortesReady) {
      transparent = true;
    }

    state as CortesReady;
    final currentCorte = state.selectedCorte;
    final abajoId = currentCorte.abajoId;
    if (abajoId == null) {
      transparent = true;
    }

    return IconButton(
      onPressed: () {
        final state = context.read<CortesCubit>().state;
        if (state is! CortesReady) {
          return;
        }
        final currentCorte = state.selectedCorte;
        final abajoId = currentCorte.abajoId;

        final corteTo = state.cortes.firstWhereOrNull(
          (corte) => corte.id == abajoId,
        );

        if (corteTo == null) {
          return;
        }

        context.read<CortesCubit>().selectCorte(corteTo);
      },
      icon: const Icon(Icons.arrow_downward),
      color: transparent ? Colors.transparent : null,
    );
  }

  Widget _buildAtrasButton(BuildContext context) {
    bool transparent = false;
    final state = context.read<CortesCubit>().state;
    if (state is! CortesReady) {
      transparent = true;
    }

    state as CortesReady;
    final currentCorte = state.selectedCorte;
    final atrasId = currentCorte.atrasId;
    if (atrasId == null) {
      transparent = true;
    }

    return IconButton(
      onPressed: () {
        final state = context.read<CortesCubit>().state;
        if (state is! CortesReady) {
          return;
        }
        final currentCorte = state.selectedCorte;
        final atrasId = currentCorte.atrasId;

        final corteTo = state.cortes.firstWhereOrNull(
          (corte) => corte.id == atrasId,
        );

        if (corteTo == null) {
          return;
        }

        context.read<CortesCubit>().selectCorte(corteTo);
      },
      icon: const Icon(Icons.undo),
      color: transparent ? Colors.transparent : null,
    );
  }

  Widget _buildInteractiveIlustration(
      CortesReady cortesState, BuildContext context) {
    final width = context.mediaQuery.size.width;

    final viewWidth = width > 840 ? width * 0.40 : width * 0.8;
    return Center(
      child: SizedBox(
        width: viewWidth,
        child: InteractiveIlustracion(
          key: ValueKey(cortesState.selectedCorte.id),
          corteCerebro: cortesState.selectedCorte,
          showVistas: cortesState.isShowingVistas,
          onEstructuraTap: (segmento) {
            if (segmento.id == cortesState.selectedSegmento?.id) {
              context.read<CortesCubit>().selectSegmento(null);
              return;
            }
            context.read<CortesCubit>().selectSegmento(segmento);
          },
          onVistaTap: (vista) {
            context.read<CortesCubit>().selectCorteById(vista.toCorteId);
          },
          highlightedSegmentos: cortesState.selectedSegmento != null
              ? [cortesState.selectedSegmento!]
              : [],
          imageMode: cortesState.imageMode,
          onImageModeChange: (mode) {
            context.read<CortesCubit>().changeImageMode(mode);
          },
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
      CortesReady cortesState, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(child: _buildAtrasButton(context)),
            Expanded(child: _buildArribaButton(context)),
            const Spacer(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIzquierdaButton(context),
            _buildDerechaButton(context),
          ],
        ),
        _buildAbajoButton(context),
      ],
    );
  }

  Widget _buildPanel(
    ScrollController sc,
    SegmentoCerebro? segmento,
    List<CorteCerebro> cortes,
    CorteCerebro currentCorte,
    ImageMode imageMode,
    BuildContext context,
  ) {
    if (segmento == null) {
      return const SizedBox.shrink();
    }
    // all cortes is all cortes without the current corte
    final allCortes =
        cortes.where((corte) => corte.id != currentCorte.id).toList();

    final allCortesWithSegmento = allCortes.where((corte) {
      return corte.segmentos.any((s) => s.id == segmento.id);
    }).toList();
    return EstructuraDetailsPanel(
      segmento: segmento,
      scrollController: sc,
      allCortes: allCortesWithSegmento,
      imageMode: imageMode,
    );
  }
}
