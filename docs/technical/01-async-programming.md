# Programación Asíncrona en Flutter

> **Nivel**: Intermedio
> **Prerrequisitos**: Conceptos básicos de Flutter, widgets y estado
> **Tiempo de lectura**: 15-20 minutos

## Introducción

La programación asíncrona es como pedir comida a domicilio. Cuando haces un pedido por teléfono (inicias una operación asíncrona), no te quedas parado esperando con el teléfono en la mano hasta que llegue la comida. En lugar de eso, cuelgas y continúas con tus actividades (la app se mantiene responsiva): puedes ver televisión, limpiar la casa, o hacer cualquier otra cosa. Cuando el repartidor toca el timbre (la operación asíncrona se completa), atiendes la puerta y recibes tu comida (await del resultado).

En Flutter, muchas operaciones toman tiempo: cargar datos desde Internet, leer archivos, consultar una base de datos, o llamar a una API de inteligencia artificial. Si la aplicación esperara "congelada" mientras estas operaciones se completan, la interfaz se vería bloqueada y el usuario no podría hacer nada. Esto crearía una experiencia terrible.

La programación asíncrona permite que tu aplicación ejecute estas operaciones que toman tiempo en segundo plano, manteniendo la interfaz fluida y responsiva. Mientras se cargan los datos del cerebro desde Firebase, el usuario puede ver un indicador de carga y la interfaz sigue respondiendo a toques y gestos.

### ¿Qué significa "asíncrono"?

Piensa en dos formas de lavar ropa:

**Síncrono** (secuencial): Lavas la ropa a mano, esperando junto a la lavadora, sin hacer nada más hasta que termine. Solo cuando termina de lavar, comienzas a secar. Solo cuando termina de secar, comienzas a planchar. Una tarea a la vez, esperando que cada una termine.

**Asíncrono** (paralelo): Pones la ropa en la lavadora automática, y mientras se lava (operación en segundo plano), preparas el desayuno, revisas el correo, o haces ejercicio. Cuando la lavadora avisa que terminó (notificación), transfieres la ropa a la secadora. Mientras se seca, continúas con otras actividades. Múltiples tareas progresando al mismo tiempo.

En programación, lo asíncrono significa que tu código puede iniciar una operación larga y continuar ejecutando otras instrucciones sin esperar que esa operación termine. Cuando la operación completa, el código "regresa" para manejar el resultado.

### Future: Una promesa de valor futuro

En Dart, un `Future` representa un valor que estará disponible en algún momento del futuro. Es como un ticket de reclamo que te dan en una tintorería: no tienes la ropa limpia todavía, pero tienes la promesa de que estará lista más tarde.

Imagina que pides un café en una cafetería con mucha gente:
- El cajero te da un número (Future)
- Puedes sentarte, revisar tu teléfono, hablar con amigos (código continúa ejecutándose)
- Cuando tu café está listo, llaman tu número (Future se completa)
- Recoges tu café (obtienes el valor del Future)

### async y await: Haciendo el código legible

Las palabras clave `async` y `await` hacen que el código asíncrono se vea casi como código síncrono normal, haciéndolo mucho más fácil de leer y entender.

- `async`: Marca una función que contiene operaciones asíncronas. Le dice a Dart: "Esta función puede tomar tiempo y devolverá un Future".
- `await`: Pausa la ejecución de la función hasta que un Future se complete. Le dice a Dart: "Espera aquí hasta que este valor esté listo, pero mientras tanto deja que otras cosas en la app continúen".

Es como decir: "Voy a hacer esta tarea que toma tiempo (async), y en ciertos puntos voy a esperar resultados específicos (await), pero no voy a bloquear toda la aplicación mientras espero".

### Estados de carga en la interfaz

Cuando realizas operaciones asíncronas, la interfaz debe reflejar tres estados principales:

1. **Cargando (Loading)**: La operación está en progreso. Muestra un spinner o indicador de progreso.
2. **Éxito (Success/Loaded)**: La operación completó exitosamente. Muestra los datos obtenidos.
3. **Error (Failure)**: Algo salió mal. Muestra un mensaje de error claro.

Piensa en esperar un paquete por correo:
- **Cargando**: "Tu paquete está en camino" - ves el ícono del camión en movimiento
- **Éxito**: "Tu paquete fue entregado" - tienes el paquete en tus manos
- **Error**: "No se pudo entregar tu paquete" - recibes una notificación de problema

En esta aplicación de neuroanatomía, estos estados son manejados por los Cubits (gestores de estado) que emiten diferentes estados según el progreso de las operaciones asíncronas.

---

## Documentación Técnica Formal

### Fundamento Teórico

La programación asíncrona en Dart permite la ejecución no bloqueante de operaciones que requieren tiempo significativo, utilizando el tipo `Future<T>` para operaciones únicas y `Stream<T>` para secuencias de eventos. Este paradigma es fundamental en aplicaciones modernas donde las operaciones de I/O (entrada/salida), solicitudes de red y acceso a bases de datos no deben bloquear el hilo principal de ejecución de la interfaz de usuario.

Dart implementa la asincronía mediante un modelo de concurrencia basado en un event loop de un solo hilo, similar al de JavaScript. A diferencia de los hilos tradicionales que requieren sincronización compleja y pueden sufrir de condiciones de carrera (race conditions), el event loop de Dart procesa eventos de forma secuencial en un bucle continuo, garantizando que solo una operación se ejecute a la vez en el contexto de ejecución principal.

#### El Event Loop de Dart

El runtime de Dart mantiene dos colas de eventos:

1. **Event Queue** (Cola de Eventos): Maneja eventos externos como I/O, drawing events, timers y mensajes.
2. **Microtask Queue** (Cola de Microtareas): Tiene mayor prioridad, se usa para tareas internas que deben completarse antes que los eventos externos.

El event loop ejecuta el siguiente algoritmo:
```
while (microTaskQueue is not empty) {
  execute next microtask
}
while (eventQueue is not empty) {
  execute next event
}
```

#### Future\<T\>: Computaciones Asíncronas

Un `Future<T>` es un objeto que representa el resultado eventual de una computación asíncrona. Puede estar en tres estados:

1. **Uncompleted** (Incompleto): La operación asíncrona aún está en progreso.
2. **Completed with a value**: La operación finalizó exitosamente y produjo un valor de tipo `T`.
3. **Completed with an error**: La operación falló y produjo una excepción.

La sintaxis `async`/`await` es azúcar sintáctica (syntactic sugar) construida sobre el mecanismo de Futures y callbacks, permitiendo escribir código asíncrono de forma imperativa y secuencial en lugar de mediante cadenas de callbacks anidados (callback hell).

Una función marcada con `async` automáticamente devuelve un `Future`, incluso si no está explícitamente declarado. El compilador de Dart transforma el cuerpo de la función en una máquina de estados que puede pausarse y reanudarse en puntos de `await`.

#### Stream\<T\>: Secuencias Asíncronas

Mientras que `Future` representa un único valor futuro, `Stream<T>` representa una secuencia de valores que llegan a lo largo del tiempo. Es el equivalente asíncrono de un `Iterable`.

Los Streams son fundamentales para:
- Escuchar cambios en tiempo real de bases de datos (como Firestore)
- Procesar datos de entrada del usuario
- Manejar eventos de sensores
- Recibir actualizaciones del servidor mediante WebSockets

### Implementación en la Aplicación NeuroAnatomía

Esta aplicación utiliza programación asíncrona extensivamente para todas las operaciones que involucran Firebase, APIs externas y procesamiento de datos. Los patrones principales se encuentran en los Cubits, que encapsulan la lógica de negocio asíncrona y gestionan los estados de carga.

#### Patrón 1: Autenticación Asíncrona

El `AuthCubit` maneja operaciones de autenticación que requieren comunicación con Firebase Authentication:

```dart
// /lib/cubits/auth_cubit/auth_cubit.dart:20-28
Future<void> login(String email, String password) async {
  emit(AuthLoading(email: email, password: password));
  try {
    final user = await authRepository.login(email, password);
    if (user != null) emit(AuthSuccess(user: user));
  } catch (e) {
    emit(AuthFailure(message: e.toString()));
  }
}
```

**Análisis técnico:**
1. El método `login` está marcado como `async`, retornando implícitamente `Future<void>`
2. Inmediatamente emite un estado `AuthLoading` para actualizar la UI con indicadores de progreso
3. El bloque `try-catch` envuelve operaciones que pueden fallar
4. `await authRepository.login(email, password)` pausa la ejecución del método hasta que Firebase responda, pero no bloquea el event loop ni la UI
5. Dependiendo del resultado, emite `AuthSuccess` o `AuthFailure`

Este patrón de emisión de estados durante el flujo asíncrono permite que la UI reaccione en cada etapa: muestra un spinner durante la carga, navega a la página principal en éxito, o muestra un mensaje de error en caso de falla.

#### Patrón 2: Carga de Datos desde Firebase

El `CortesCubit` carga datos de cortes cerebrales desde Cloud Firestore:

```dart
// /lib/cubits/cortes_cubit.dart/cortes_cubit.dart:15-24
Future<void> getCortes() async {
  emit(CortesLoading());
  try {
    final List<CorteCerebro> cortes = await _cortesService.getCortes();
    emit(CortesReady(cortes: cortes, selectedCorte: cortes.first));
  } catch (e) {
    emit(CortesError(message: e.toString()));
    rethrow;
  }
}
```

**Análisis técnico:**
1. Emite `CortesLoading()` para activar indicadores de carga en la UI
2. `await _cortesService.getCortes()` espera la respuesta de Firestore sin bloquear
3. El servicio internamente realiza queries a Firestore, deserializa JSON a objetos Dart, y construye estructuras de datos complejas
4. `rethrow` propaga la excepción después de emitir el estado de error, permitiendo logging o manejo en capas superiores

#### Patrón 3: Integración con API de OpenAI

El `QuizCubit` genera quizzes usando la API de OpenAI (GPT-3.5-turbo):

```dart
// /lib/cubits/quiz_cubit/quiz_cubit.dart:12-20
Future<void> generateQuiz(String text) async {
  emit(QuizLoading());
  try {
    final quiz = await ChatGPTService.generateQuiz(text);
    emit(QuizLoaded(quiz: quiz));
  } catch (e) {
    emit(QuizError(message: e.toString()));
  }
}
```

El método `ChatGPTService.generateQuiz` es particularmente interesante porque encadena múltiples operaciones asíncronas:

```dart
// /lib/services/chat_gpt_service.dart:7-60
static Future<Quiz> generateQuiz(String text) async {
  try {
    final quizResponse = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      responseFormat: {"type": "json_object"},
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'When I send text, create a small quiz...'
            )
          ],
          role: OpenAIChatMessageRole.system,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(text)
          ],
          role: OpenAIChatMessageRole.user,
        )
      ],
      temperature: 0.3,
      maxTokens: 1000,
    );

    final quizStr = quizResponse.choices.first.message.content?.first.text;

    if (quizStr == null || quizStr.isEmpty) {
      throw Exception('Quiz not generated: empty response');
    }

    final quizJson = json.decode(quizStr);
    // ... validación y procesamiento
    return Quiz.fromJson(quizJson);
  } catch (e) {
    throw Exception('Error generating quiz: $e');
  }
}
```

**Análisis técnico:**
1. Una única operación `await` espera la respuesta completa de la API de OpenAI
2. El procesamiento subsecuente (parsing JSON, validación) es síncrono
3. La función retorna `Future<Quiz>`, permitiendo que el caller use `await`
4. El manejo robusto de errores valida la respuesta antes de deserializar

### Manejo de Errores en Código Asíncrono

El manejo de errores en código asíncrono sigue principios similares al código síncrono, pero con consideraciones adicionales:

#### try-catch en funciones async

```dart
Future<void> someAsyncOperation() async {
  try {
    final result = await riskyOperation();
    emit(SuccessState(result));
  } catch (e) {
    emit(ErrorState(e.toString()));
  }
}
```

Las excepciones lanzadas dentro de un `Future` se capturan con `try-catch` cuando se usa `await`. Sin `await`, las excepciones se capturarían usando `.catchError()` en el Future.

#### Error propagation con rethrow

En `CortesCubit.getCortes()` (línea 22), vemos `rethrow`:

```dart
catch (e) {
  emit(CortesError(message: e.toString()));
  rethrow;  // Propaga la excepción después de manejarla localmente
}
```

Esto permite:
1. Manejar el error localmente (emitir estado de error)
2. Permitir que capas superiores también reaccionen al error (logging, analytics, etc.)

### Estados de Carga y Máquinas de Estado

Cada Cubit en la aplicación implementa una máquina de estado que refleja el ciclo de vida de las operaciones asíncronas:

**AuthCubit states:**
- `AuthInitial` → `AuthLoading` → `AuthSuccess` | `AuthFailure`

**CortesCubit states:**
- `CortesInitial` → `CortesLoading` → `CortesReady` | `CortesError`

**QuizCubit states:**
- `QuizInitial` → `QuizLoading` → `QuizLoaded` | `QuizError`

Este patrón garantiza que la UI siempre tenga suficiente información para renderizar el estado apropiado: spinners durante la carga, contenido en éxito, mensajes de error en fallos.

### Especificaciones Técnicas

#### Future Chaining

Aunque esta aplicación usa principalmente `async`/`await`, es importante entender que el código equivalente sin syntactic sugar sería:

```dart
// Con async/await
Future<void> example() async {
  final result = await operation1();
  final result2 = await operation2(result);
  return result2;
}

// Equivalente sin async/await
Future<void> example() {
  return operation1()
    .then((result) => operation2(result))
    .then((result2) => result2);
}
```

El compilador transforma el código `async`/`await` en un patrón similar internamente.

#### Parallel Async Operations

Para ejecutar múltiples operaciones asíncronas en paralelo:

```dart
Future<void> loadMultipleResources() async {
  final results = await Future.wait([
    loadResource1(),
    loadResource2(),
    loadResource3(),
  ]);
  // results es una List con los resultados en orden
}
```

`Future.wait` retorna un Future que completa cuando todos los Futures en la lista completan.

#### Timeout para Operaciones Largas

```dart
Future<Data> fetchWithTimeout() async {
  try {
    return await operation().timeout(Duration(seconds: 30));
  } on TimeoutException {
    throw Exception('Operation took too long');
  }
}
```

### Mejores Prácticas

1. **Siempre use async/await para código asíncrono**: Es más legible que callbacks o `then()` chains.

2. **Envuelva código asíncrono en try-catch**: Las operaciones que involucran red, disco o servicios externos pueden fallar.

3. **Emita estados de carga apropiados**: La UI debe reflejar el estado actual de operaciones asíncronas.

4. **No use `await` dentro de loops si las operaciones pueden ejecutarse en paralelo**: Use `Future.wait()` en su lugar.

```dart
// Lento - operaciones secuenciales
for (var item in items) {
  await processItem(item);
}

// Rápido - operaciones en paralelo
await Future.wait(items.map((item) => processItem(item)));
```

5. **Use `unawaited()` para Futures que intencionalmente no necesitan ser esperados**:

```dart
import 'package:flutter/foundation.dart';

unawaited(analyticsService.logEvent('user_action'));
```

6. **Considere timeouts para operaciones que pueden colgarse**:

```dart
final data = await apiCall().timeout(Duration(seconds: 30));
```

### Desafíos Comunes

#### 1. Olvidar await

```dart
// Incorrecto - no espera el resultado
void login() async {
  authRepository.login(email, password);  // Falta await
  emit(AuthSuccess());  // Se ejecuta inmediatamente
}

// Correcto
void login() async {
  final user = await authRepository.login(email, password);
  emit(AuthSuccess(user: user));
}
```

#### 2. No marcar función como async cuando usa await

```dart
// Error de compilación
void login() {
  final user = await authRepository.login(email, password);
}

// Correcto
Future<void> login() async {
  final user = await authRepository.login(email, password);
}
```

#### 3. No manejar errores

```dart
// Riesgoso - errores sin manejar pueden crashear la app
Future<void> loadData() async {
  final data = await service.getData();
  emit(DataLoaded(data));
}

// Seguro
Future<void> loadData() async {
  try {
    final data = await service.getData();
    emit(DataLoaded(data));
  } catch (e) {
    emit(DataError(e.toString()));
  }
}
```

#### 4. Usar async sin await

Si una función está marcada como `async` pero no usa `await`, probablemente no necesita ser `async`:

```dart
// Innecesario
Future<void> doSomething() async {
  print('Hello');
}

// Mejor
void doSomething() {
  print('Hello');
}
```

## Referencias

### Documentación Interna
- [BLoC Pattern Fundamentals](/docs/bloc-pattern/01-bloc-pattern-fundamentals.md) - Cómo los Cubits gestionan estado asíncrono
- [Firebase Integration](/docs/firebase/01-firebase-fundamentals.md) - Operaciones asíncronas con Firebase
- [Services and Repositories](/docs/firebase/04-services-and-repositories.md) - Implementación de servicios asíncronos

### Referencias Externas
1. Dart Language (2024). "Asynchronous Programming: Futures, async, await". https://dart.dev/codelabs/async-await
2. Dart Language Documentation (2024). "Asynchronous Programming Guide". https://dart.dev/guides/language/language-tour#asynchrony-support
3. Flutter Documentation (2024). "Asynchronous programming: futures, async, await". https://docs.flutter.dev/cookbook/networking/fetch-data
4. Freeman, E. (2020). "Asynchronous Programming in Dart and Flutter". O'Reilly Media.
5. Soares, P. (2021). "Flutter Complete Reference". Alberto Miola. Chapter 8: Asynchronous Programming.

## Lecturas Adicionales

- [JSON Serialization](/docs/technical/02-json-serialization.md) - Cómo se deserializan datos de Firebase y APIs
- [Dependency Injection](/docs/technical/03-dependency-injection.md) - Cómo se inyectan servicios asíncronos en los Cubits
- [AI Quiz Generation](/docs/features/04-ai-quiz-generation.md) - Ejemplo completo de integración asíncrona con API externa
- [Notes and User Data](/docs/features/03-notes-and-user-data.md) - Streams de Firestore para actualizaciones en tiempo real
