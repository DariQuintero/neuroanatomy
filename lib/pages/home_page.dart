import 'package:flutter/material.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/ilustracion_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/pages/notes_page/notes_page.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/corte_de_charcot.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/giro_precentral.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/giro_temporal_superior.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> segmentosTocados = [false, false];
  bool showCortes = false;

  @override
  Widget build(BuildContext context) {
    // get the svg string from the assets
    final width = MediaQuery.of(context).size.width;
    const aspectRatio = 0.752;
    IlustracionCerebro ilustracion = IlustracionCerebro(
      id: 'lateral_izquierdo',
      nombre: 'Corte transversal',
      realPath: 'assets/cerebro1/lateral_izquierdo/recortado.png',
      estructuras: [
        EstructuraCerebro(
          id: 'giro_precentral',
          nombre: 'Giro Precentral',
          painter: GiroPrecentral(highlight: segmentosTocados[0]),
        ),
        EstructuraCerebro(
          id: 'giro_temporal_superior',
          nombre: 'Giro Temporal Superior',
          painter: GiroTemporalSuperior(highlight: segmentosTocados[1]),
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
      appBar: AppBar(
        title: Text(ilustracion.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              setState(() {
                showCortes = !showCortes;
              });
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _buildIlustracion(ilustracion, width, aspectRatio, context),
          ),
        ],
      ),
    );
  }

  Stack _buildIlustracion(IlustracionCerebro ilustracion, double width,
      double aspectRatio, BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          ilustracion.realPath,
          width: width,
          height: width * aspectRatio,
          fit: BoxFit.cover,
        ),
        ...ilustracion.estructuras.map((estructura) {
          return GestureDetector(
            child: CustomPaint(
              size: Size(width, width * aspectRatio),
              painter: estructura.painter,
            ),
            onTapDown: (details) {
              setState(() {
                segmentosTocados[ilustracion.estructuras.indexOf(estructura)] =
                    true;
              });
            },
            onTapUp: (details) {
              setState(() {
                segmentosTocados[ilustracion.estructuras.indexOf(estructura)] =
                    false;
              });
            },
            onTapCancel: () {
              setState(() {
                segmentosTocados[ilustracion.estructuras.indexOf(estructura)] =
                    false;
              });
            },
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotesPage(estructura: estructura),
                ),
              );
            },
          );
        }).toList(),
        if (showCortes)
          ...ilustracion.cortes.map((corte) {
            return GestureDetector(
              child: CustomPaint(
                size: Size(width, width * aspectRatio),
                painter: corte.painter,
              ),
              onTap: () {
                // show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(corte.nombre),
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}
