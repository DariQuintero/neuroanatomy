import 'package:flutter/material.dart';
import 'package:neuroanatomy/models/ilustracion_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/giro_precentral.dart';
import 'package:neuroanatomy/painters/cerebro1/lateral_izquierdo/giro_temporal_superior.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> segmentosTocados = [false, false];

  @override
  Widget build(BuildContext context) {
    // get the svg string from the assets
    final width = MediaQuery.of(context).size.width;
    const aspectRatio = 0.752;
    IlustracionCerebro ilustracion = IlustracionCerebro(
      nombre: 'Corte transversal',
      realPath: 'assets/cerebro1/lateral_izquierdo/recortado.png',
      segmentos: [
        SegmentoCerebro(
          nombre: 'Giro Precentral',
          painter: GiroPrecentral(highlight: segmentosTocados[0]),
        ),
        SegmentoCerebro(
            nombre: 'Giro Temporal Superior',
            painter: GiroTemporalSuperior(highlight: segmentosTocados[1])),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                // show the border with red color
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                ),
                child: Image.asset(
                  ilustracion.realPath,
                  width: width,
                  height: width * aspectRatio,
                  fit: BoxFit.cover,
                ),
              ),
              ...ilustracion.segmentos.map((segmento) {
                return GestureDetector(
                  child: CustomPaint(
                    size: Size(width, width * aspectRatio),
                    painter: segmento.painter,
                  ),
                  onTapDown: (details) {
                    setState(() {
                      segmentosTocados[
                          ilustracion.segmentos.indexOf(segmento)] = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      segmentosTocados[
                          ilustracion.segmentos.indexOf(segmento)] = false;
                    });
                  },
                  onTap: () {},
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
