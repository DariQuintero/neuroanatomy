import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/diagramas_cubit/diagramas_cubit.dart';
import 'package:neuroanatomy/models/diagrama.dart';
import 'package:neuroanatomy/services/diagramas_service.dart';

class DiagramasPage extends StatelessWidget {
  final DiagramaType type;
  const DiagramasPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(type.title),
        ),
        body: BlocProvider<DiagramasCubit>(
          create: (context) =>
              DiagramasCubit(DiagramasService(), type: type)..getDiagramas(),
          child: _DiagramasPageDisplay(type: type),
        ));
  }
}

class _DiagramasPageDisplay extends StatelessWidget {
  final DiagramaType type;
  const _DiagramasPageDisplay({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiagramasCubit, DiagramasState>(
      builder: (context, state) {
        if (state is DiagramasLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DiagramasLoaded) {
          final diagramas = state.diagramas
              .where((diagrama) => diagrama.type == type)
              .toList();
          if (diagramas.isEmpty) {
            return const Center(
              child: Text('No hay diagramas'),
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: diagramas
                      .map((diagrama) => _DiagramaCard(
                            diagrama: diagrama,
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        } else if (state is DiagramasError) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return const Center(
            child: Text('Error'),
          );
        }
      },
    );
  }
}

class _DiagramaCard extends StatelessWidget {
  final Diagrama diagrama;
  const _DiagramaCard({
    required this.diagrama,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final imageProvider = CachedNetworkImageProvider(diagrama.imageUrl);
        showImageViewer(context, imageProvider, doubleTapZoomable: true);
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: Card(
          child: Column(
            children: [
              Container(
                height: 164,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: diagrama.imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 250),
                  progressIndicatorBuilder: (context, url, progress) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      diagrama.nombre,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
