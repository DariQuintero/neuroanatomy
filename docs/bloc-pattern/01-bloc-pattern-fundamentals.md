# Fundamentos del Patrón BLoC

> **Nivel**: Intermedio
> **Prerrequisitos**: Widgets y UI, Introducción a State Management
> **Tiempo de lectura**: 15 minutos

## Introducción

Imagina que tu aplicación es como un restaurante. Los clientes (la interfaz de usuario) hacen pedidos (eventos), pero no entran directamente a la cocina a cocinar. En lugar de eso, un mesero toma el pedido y lo lleva a la cocina (el BLoC). La cocina procesa el pedido siguiendo recetas específicas (lógica de negocio) y cuando la comida está lista (nuevo estado), el mesero la lleva de vuelta al cliente. Este flujo organizado asegura que la cocina pueda cambiar su forma de trabajar sin afectar cómo los clientes hacen sus pedidos, y viceversa.

El patrón BLoC (Business Logic Component) fue presentado por Google en 2018 como una solución para manejar el estado de las aplicaciones Flutter de manera predecible y organizada. La idea central es simple pero poderosa: separar completamente la lógica de negocio de la interfaz de usuario.

### ¿Por qué necesitamos BLoC?

Cuando una aplicación crece, manejar el estado con `setState()` se vuelve caótico. Imagina una aplicación con 50 pantallas diferentes, todas compartiendo información del usuario autenticado. Si cada pantalla maneja su propia copia de los datos del usuario con `setState()`, terminarías con:

- Código duplicado en todas partes
- Datos inconsistentes entre pantallas
- Difícil de probar (la lógica está mezclada con la UI)
- Imposible de reutilizar la lógica en otras plataformas (como una versión web)

BLoC resuelve estos problemas actuando como un "administrador central" que:
1. Recibe solicitudes (eventos) desde la UI
2. Ejecuta la lógica de negocio necesaria
3. Emite nuevos estados que la UI puede mostrar

### El Flujo Unidireccional

BLoC se basa en el concepto de flujo unidireccional de datos:

```
UI → Evento → BLoC → Estado → UI
```

Este flujo siempre va en una dirección, lo que hace que el comportamiento de la app sea predecible. La UI nunca modifica el estado directamente; siempre debe pasar por el BLoC. Esto es como tener reglas claras en el restaurante: los clientes no pueden entrar a la cocina, deben comunicarse a través del mesero.

### Streams: El Corazón de BLoC

Para entender BLoC, necesitas entender los Streams en Dart. Un Stream es como una tubería por donde fluyen datos a lo largo del tiempo. Piensa en una cinta transportadora: puedes poner objetos en un extremo (Sink) y recogerlos en el otro extremo (Stream).

```dart
// Crear un stream de números
Stream<int> contadorStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // "yield" emite un valor al stream
  }
}

// Escuchar el stream
contadorStream().listen((numero) {
  print('Número: $numero'); // Se imprime cada segundo
});
```

BLoC usa Streams para emitir estados. Cada vez que algo cambia en la aplicación (el usuario presiona un botón, llegan datos del servidor), el BLoC emite un nuevo estado a través de su Stream, y todos los widgets que están "escuchando" se reconstruyen automáticamente con la nueva información.

### Separación de Responsabilidades

El principio fundamental de BLoC es la separación de responsabilidades:

- **UI (Widgets)**: Solo se encarga de mostrar información y capturar interacciones del usuario
- **BLoC**: Contiene toda la lógica de negocio y emite estados
- **Repository/Service**: Maneja el acceso a datos (APIs, bases de datos)

Esta separación tiene beneficios enormes:
- **Testeable**: Puedes probar la lógica sin necesidad de widgets
- **Reutilizable**: El mismo BLoC puede usarse en diferentes pantallas
- **Mantenible**: Cada capa tiene una responsabilidad clara
- **Multiplataforma**: La lógica funciona igual en iOS, Android, Web

---

## Documentación Técnica Formal

### Fundamento Teórico

El patrón BLoC (Business Logic Component) es un patrón arquitectónico de gestión de estado introducido por Paolo Soares y Cong Hui durante Google I/O 2018. BLoC implementa principios de programación reactiva utilizando Streams de Dart para establecer un flujo unidireccional de datos entre la capa de presentación y la capa de lógica de negocio.

El patrón se fundamenta en tres principios arquitectónicos principales:

1. **Separación de Preocupaciones (Separation of Concerns)**: La lógica de negocio reside exclusivamente en componentes BLoC, completamente desacoplada de la capa de presentación.

2. **Flujo Unidireccional de Datos (Unidirectional Data Flow)**: Los datos fluyen en una única dirección: UI → Events → BLoC → States → UI. Esta arquitectura elimina mutaciones de estado impredecibles.

3. **Programación Reactiva**: Utiliza Streams (implementación de Observer pattern) para propagar cambios de estado de forma asíncrona y declarativa.

### Arquitectura del Patrón BLoC

La arquitectura BLoC consta de cuatro componentes fundamentales:

#### 1. Events (Eventos)

Los eventos son objetos inmutables que representan intenciones del usuario o del sistema. Cada evento describe una acción específica que debe procesarse.

```dart
// Ejemplo conceptual
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}
```

#### 2. States (Estados)

Los estados son objetos inmutables que representan el estado actual de una parte de la aplicación. La UI se reconstruye en respuesta a nuevos estados.

```dart
// Ejemplo conceptual
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
```

#### 3. BLoC Component

El componente BLoC contiene la lógica de negocio. Recibe eventos a través de un Sink y emite estados a través de un Stream.

```dart
// Estructura conceptual de un BLoC
class AuthBloc {
  // Stream de estados (salida)
  Stream<AuthState> get state => _stateController.stream;
  final _stateController = StreamController<AuthState>();

  // Sink de eventos (entrada)
  Sink<AuthEvent> get events => _eventController.sink;
  final _eventController = StreamController<AuthEvent>();

  AuthBloc() {
    // Escuchar eventos y procesarlos
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(AuthEvent event) async {
    if (event is LoginRequested) {
      _stateController.add(AuthLoading());
      try {
        final user = await repository.login(event.email, event.password);
        _stateController.add(AuthSuccess(user));
      } catch (e) {
        _stateController.add(AuthFailure(e.toString()));
      }
    }
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
```

#### 4. UI Layer

La capa de presentación consume el Stream de estados y emite eventos en respuesta a interacciones del usuario.

```dart
// Ejemplo conceptual
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: authBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state is AuthLoading) {
          return CircularProgressIndicator();
        }

        if (state is AuthSuccess) {
          return Text('Welcome ${state.user.name}');
        }

        return LoginForm(
          onSubmit: (email, password) {
            authBloc.events.add(LoginRequested(email, password));
          },
        );
      },
    );
  }
}
```

### Programación Reactiva con Streams

BLoC aprovecha el sistema de Streams de Dart, que implementa el patrón Observer. Un Stream permite que múltiples suscriptores (widgets) reaccionen a cambios de estado sin acoplamiento directo.

**Características de Streams**:
- **Asíncronos**: Los datos llegan a lo largo del tiempo
- **Unicast o Broadcast**: Single listener o múltiples listeners
- **Composables**: Pueden transformarse con operadores (map, where, debounce)
- **Cancelables**: Las suscripciones pueden cancelarse para evitar memory leaks

```dart
// Transformación de streams
Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);

// Operadores de transformación
final doubled = numbers.map((n) => n * 2);
final evens = numbers.where((n) => n.isEven);
```

### Ventajas del Patrón BLoC

1. **Testabilidad**: La lógica de negocio puede probarse sin dependencias de Flutter Framework
2. **Reutilización**: BLoCs pueden compartirse entre múltiples widgets y plataformas
3. **Predictibilidad**: El flujo unidireccional hace que el estado sea predecible
4. **Escalabilidad**: Estructura clara para aplicaciones grandes
5. **Independencia de plataforma**: La lógica funciona en iOS, Android, Web, Desktop

### Desventajas y Consideraciones

1. **Boilerplate**: Requiere definir clases para eventos y estados
2. **Curva de aprendizaje**: Requiere entender Streams y programación reactiva
3. **Overhead**: Para aplicaciones simples puede ser excesivo
4. **Gestión de memoria**: Importante cerrar StreamControllers para evitar leaks

### Especificaciones Técnicas

**Lifecycle de un BLoC**:
1. Creación: Se inicializan StreamControllers
2. Uso: Se escuchan eventos y emiten estados
3. Disposición: Se cierran todos los StreamControllers

**Mejores Prácticas**:
- Siempre implementar método `dispose()` o `close()`
- Estados deben ser inmutables (usar `@immutable` o `Equatable`)
- Un BLoC por característica funcional
- Nunca exponer Sinks públicamente, solo métodos específicos
- Usar transformadores para debounce/throttle cuando sea necesario

### Evolución: De BLoC a Cubit

El patrón BLoC tradicional, aunque poderoso, resultaba verboso para casos simples. Esto llevó a la creación de Cubit, una simplificación del patrón que elimina eventos explícitos en favor de métodos directos. Cubit mantiene los beneficios de BLoC con menos código boilerplate.

```dart
// Cubit - Simplificado
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

// vs BLoC tradicional - Más verboso pero más explícito
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is IncrementPressed) {
      yield state + 1;
    } else if (event is DecrementPressed) {
      yield state - 1;
    }
  }
}
```

La aplicación NeuroAnatomía utiliza principalmente Cubit, que se explorará en detalle en el siguiente documento.

## Referencias

### Documentación Interna
- [Cubit: BLoC Simplificado](./02-cubit-simplified-bloc.md) - Siguiente lectura recomendada
- [BLoC en la Aplicación NeuroAnatomía](./03-bloc-in-neuroanatomy-app.md)
- [Introducción a State Management](/docs/flutter-basics/03-state-management-intro.md)

### Referencias Externas
1. Soares, P., & Mehta, S. (2018). "Build reactive mobile apps with Flutter" - Google I/O 2018. https://www.youtube.com/watch?v=RS36gBEp8OI
2. BLoC Library Documentation - https://bloclibrary.dev
3. Angelov, F. (2020). "BLoC Architecture". https://bloclibrary.dev/#/architecture
4. Dart Language - Asynchronous Programming: Streams. https://dart.dev/tutorials/language/streams
5. Soares, P. (2021). *Flutter Complete Reference*. Alberto Miola.
6. Martin, R. C. (2017). *Clean Architecture*. Prentice Hall. (Principio de Separación de Responsabilidades)

## Lecturas Adicionales

**Siguiente paso recomendado**: Lee [Cubit: BLoC Simplificado](./02-cubit-simplified-bloc.md) para entender la implementación específica que usa esta aplicación.

**Temas relacionados**:
- Programación reactiva con Streams en Dart
- Patrones de arquitectura de software (MVP, MVVM, MVI)
- RxDart para operadores avanzados de Streams
- Testing de BLoCs y Cubits
