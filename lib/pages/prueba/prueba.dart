import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/cubits/cortes_cubit.dart/cortes_cubit.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/services/cortes_service.dart';
import 'package:neuroanatomy/widgets/interactive_ilustracion.dart';

class Prueba extends StatefulWidget {
  const Prueba({super.key});

  @override
  State<Prueba> createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  @override
  void initState() {
    super.initState();
  }

  void test() async {
    final cortes = await CortesService().getCortes();
    print(cortes.length);
  }

  @override
  Widget build(BuildContext context) {
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

            final cortePrueba = cortes[0];

            return Center(
              child: InteractiveIlustracion(corteCerebro: cortePrueba),
            );
          },
        ),
      ),
    );
  }
}
