# Inyección de Dependencias en Flutter

> **Nivel**: Intermedio a Avanzado
> **Prerrequisitos**: BLoC pattern, arquitectura de aplicaciones, widgets en Flutter
> **Tiempo de lectura**: 20-25 minutos

## Introducción

Imagina que estás organizando una gran fiesta. Necesitas un chef, un DJ, y decoradores. Tienes dos opciones:

**Opción 1 (Sin inyección de dependencias)**: Cada persona que llega a la fiesta trae su propio chef, su propio DJ, y sus propios decoradores. Terminas con 50 chefs cocinando diferentes comidas, 50 DJs tocando música diferente, y un caos total. Además, si quieres cambiar al chef, tienes que convencer a cada invitado individualmente.

**Opción 2 (Con inyección de dependencias)**: Tú, como organizador, contratas a un chef, un DJ y decoradores. Cuando los invitados llegan, simplemente usan los servicios que ya están disponibles. Si necesitas cambiar al chef, solo cambias uno y todos automáticamente disfrutan del nuevo chef.

La inyección de dependencias funciona como la Opción 2. En lugar de que cada parte de tu aplicación cree sus propias instancias de servicios y repositorios, un "organizador central" los crea una vez y los provee a quien los necesite.

### El Problema: Dependencias Acopladas

Sin inyección de dependencias, tu código se vería así:

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Cada vez que se crea LoginPage, crea su propio AuthCubit
    final authCubit = AuthCubit(
      authRepository: AuthRepository(), // Y su propio AuthRepository
    );

    // Usar authCubit...
  }
}
```

Problemas con este enfoque:
1. **Múltiples instancias**: Cada vez que navegas a LoginPage, creas un nuevo AuthCubit y AuthRepository, perdiendo el estado
2. **Difícil de testear**: No puedes reemplazar fácilmente AuthRepository con una versión de prueba (mock)
3. **Acoplamiento fuerte**: LoginPage está "casado" con implementaciones específicas
4. **Desperdicio de memoria**: Múltiples instancias innecesarias consumen recursos

### La Solución: Proveedores

Los proveedores son como estantes en un almacén centralizado. Guardas los servicios que tu aplicación necesita en estos estantes, y cualquier widget puede ir y tomar lo que necesita.

Flutter (con el paquete `flutter_bloc`) proporciona dos tipos principales de proveedores:

**RepositoryProvider**: Para servicios y repositorios (objetos que no manejan estado de UI directamente)
**BlocProvider**: Para Cubits y BLoCs (objetos que manejan estado de UI)

### Analogía: El Sistema de Suministro de Agua

Piensa en tu casa y el sistema de agua:

**Sin inyección de dependencias**: Cada vez que quieres agua, sales con un balde, caminas hasta el pozo, sacas agua, la llevas de vuelta, y la usas. Cada habitación de la casa hace esto independientemente. Es agotador e ineficiente.

**Con inyección de dependencias**: La ciudad tiene un sistema de acueducto central. El agua se bombea desde la fuente hasta tanques principales (RepositoryProvider), luego se distribuye a través de tuberías (árbol de widgets) a cada grifo de tu casa (widgets individuales). Cuando necesitas agua, simplemente abres el grifo más cercano (context.read<T>()).

El `BuildContext` actúa como las tuberías: lleva las dependencias desde los tanques principales hasta donde se necesitan.

### context.read() vs context.watch()

Son como dos formas de obtener agua del grifo:

**context.read\<T\>()**: Abres el grifo, llenas una taza, cierras el grifo. Obtienes el servicio una vez para usarlo (no reactivo).

**context.watch\<T\>()**: Instalas un sensor que constantemente monitorea el flujo de agua y te notifica cuando cambia. Úsalo cuando quieres que tu widget se reconstruya cuando el estado cambie (reactivo).

```dart
// read: Solo quiero enviar un evento, no me interesa el estado actual
onPressed: () => context.read<AuthCubit>().login(email, password)

// watch: Quiero reconstruir mi widget cuando el estado cambie
final state = context.watch<AuthCubit>().state;
```

---

## Documentación Técnica Formal

### Fundamento Teórico

La inyección de dependencias (Dependency Injection, DI) es un patrón de diseño que implementa Inversión de Control (Inversion of Control, IoC), uno de los principios SOLID fundamentales en ingeniería de software. Específicamente, implementa el Principio de Inversión de Dependencias (Dependency Inversion Principle):

> Los módulos de alto nivel no deben depender de módulos de bajo nivel. Ambos deben depender de abstracciones. Las abstracciones no deben depender de detalles. Los detalles deben depender de abstracciones.
>
> — Robert C. Martin, "Clean Architecture" (2017)

#### Tipos de Inyección de Dependencias

1. **Constructor Injection**: Dependencias se pasan a través del constructor
2. **Setter Injection**: Dependencias se asignan mediante métodos setter
3. **Interface Injection**: Dependencias se pasan mediante interfaces

Flutter con `flutter_bloc` utiliza principalmente **Provider-based Injection**, una forma de inyección que aprovecha el árbol de widgets de Flutter para propagar dependencias hacia abajo en la jerarquía.

#### Ventajas de la Inyección de Dependencias

1. **Testability**: Facilita pruebas unitarias mediante la inyección de mocks y stubs
2. **Maintainability**: Reduce acoplamiento, facilitando cambios y refactorización
3. **Reusability**: Componentes desacoplados son más fáciles de reutilizar
4. **Single Responsibility**: Cada clase se enfoca en su responsabilidad, no en crear dependencias
5. **Lifecycle Management**: Control centralizado del ciclo de vida de objetos

### Implementación en la Aplicación NeuroAnatomía

La aplicación implementa inyección de dependencias usando `RepositoryProvider` y `BlocProvider` de la biblioteca `flutter_bloc`, aprovechando el patrón `InheritedWidget` de Flutter para propagar dependencias por el árbol de widgets.

#### Configuración en main.dart

El punto de entrada de la aplicación establece el árbol de dependencias:

```dart
// /lib/main.dart:25-70
class NeuroAnatomy extends StatelessWidget {
  const NeuroAnatomy({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'NeuroAnatomy',
        theme: mainTheme(),
        debugShowCheckedModeBanner: false,
        home: BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepository: context.read<AuthRepository>()),
          child: BlocBuilder<AuthCubit, FirebaseAuthState>(
              builder: (context, state) {
            if (state is AuthSuccess) {
              return Navigator(
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  ];
                },
              );
            } else if (state is AuthFailure ||
                state is AuthInitial ||
                state is AuthLoading) {
              return const AuthPage();
            } else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
```

**Análisis técnico:**

#### Nivel 1: MultiRepositoryProvider

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepository(),
    ),
  ],
  child: MaterialApp(...)
)
```

`MultiRepositoryProvider` es un widget de conveniencia que envuelve múltiples `RepositoryProvider` en un solo lugar. Es equivalente a:

```dart
RepositoryProvider<AuthRepository>(
  create: (context) => AuthRepository(),
  child: RepositoryProvider<OtroRepository>(
    create: (context) => OtroRepository(),
    child: MaterialApp(...)
  )
)
```

**Características clave:**

1. **Lazy Initialization**: `create` no se ejecuta hasta que alguien solicita `AuthRepository` por primera vez
2. **Singleton Scope**: Una única instancia de `AuthRepository` existe en este ámbito del árbol
3. **Disponibilidad**: Cualquier widget descendiente puede acceder mediante `context.read<AuthRepository>()`

#### Nivel 2: BlocProvider para AuthCubit

```dart
BlocProvider<AuthCubit>(
  create: (context) =>
      AuthCubit(authRepository: context.read<AuthRepository>()),
  child: BlocBuilder<AuthCubit, FirebaseAuthState>(...)
)
```

**Inyección de dependencias en acción:**

1. `create` se ejecuta cuando el widget se monta
2. `context.read<AuthRepository>()` recupera la instancia de `AuthRepository` del `RepositoryProvider` superior
3. Esta instancia se pasa al constructor de `AuthCubit`
4. `AuthCubit` almacena la referencia y la usa para operaciones de autenticación

**Ciclo de vida:**
- `AuthCubit` se crea cuando `BlocProvider` se monta
- Se destruye automáticamente cuando `BlocProvider` se desmonta
- El método `close()` del Cubit se llama automáticamente en cleanup

#### Nivel 3: BlocBuilder Consumidor

```dart
BlocBuilder<AuthCubit, FirebaseAuthState>(
  builder: (context, state) {
    if (state is AuthSuccess) {
      return Navigator(...);
    } else if (state is AuthFailure || ...) {
      return const AuthPage();
    } else {
      return const Scaffold(...);
    }
  }
)
```

`BlocBuilder` automáticamente:
1. Obtiene `AuthCubit` del `BlocProvider` superior usando `context.watch<AuthCubit>()`
2. Escucha cambios de estado
3. Reconstruye cuando el estado cambia
4. Pasa el estado actual al builder

### Patrones de Acceso a Dependencias

#### 1. context.read\<T\>() - Acceso de Solo Lectura

Úsalo cuando necesitas acceder a un provider sin reconstruir el widget cuando cambie:

```dart
onPressed: () {
  // Obtiene AuthCubit y llama método
  // Este widget NO se reconstruye cuando AuthCubit emita nuevo estado
  context.read<AuthCubit>().login(email, password);
}
```

**Cuándo usar:**
- Dentro de callbacks (onPressed, onChanged)
- Para desencadenar acciones sin reconstruir
- En métodos del ciclo de vida (initState, dispose)

**Internamente**: Llama a `Provider.of<T>(context, listen: false)`

#### 2. context.watch\<T\>() - Acceso Reactivo

Úsalo cuando quieres que el widget se reconstruya cuando la dependencia cambie:

```dart
@override
Widget build(BuildContext context) {
  // Widget se reconstruye cuando AuthCubit emite nuevo estado
  final authState = context.watch<AuthCubit>().state;

  return Text('Estado: $authState');
}
```

**Cuándo usar:**
- Dentro de métodos `build()`
- Cuando necesitas renderizar basado en el estado actual
- Para crear UI reactiva

**Internamente**: Llama a `Provider.of<T>(context, listen: true)`

**Nota importante**: Solo se puede usar en métodos `build()`. Usarlo en `initState()` o callbacks causará errores porque esos métodos no se vuelven a ejecutar en reconstrucciones.

#### 3. BlocBuilder\<B, S\> - Widget Reactivo Especializado

Widget de conveniencia que internamente usa `context.watch`:

```dart
BlocBuilder<AuthCubit, FirebaseAuthState>(
  builder: (context, state) {
    // Se reconstruye cada vez que AuthCubit emite
    return buildUIBasedOn(state);
  }
)
```

**Equivalente a:**
```dart
Builder(
  builder: (context) {
    final state = context.watch<AuthCubit>().state;
    return buildUIBasedOn(state);
  }
)
```

#### 4. BlocConsumer\<B, S\> - Listener + Builder

Combina escucha para side effects con reconstrucción de UI:

```dart
BlocConsumer<AuthCubit, FirebaseAuthState>(
  listener: (context, state) {
    // Side effects (no reconstruye UI)
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message))
      );
    }
  },
  builder: (context, state) {
    // Reconstruye UI basado en estado
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    return LoginForm();
  }
)
```

### Árbol de Dependencias

El árbol de inyección de dependencias en la aplicación sigue esta estructura:

```
MaterialApp
├─ MultiRepositoryProvider
│  └─ AuthRepository (instancia única)
│
└─ BlocProvider<AuthCubit>
   └─ AuthCubit (usa AuthRepository inyectado)
      └─ BlocBuilder
         └─ Renderiza basado en estado de Auth
            ├─ AuthPage (si no autenticado)
            └─ HomePage (si autenticado)
               └─ Nuevos providers específicos de página
```

Cualquier widget en el subárbol de `MaterialApp` puede acceder a `AuthRepository` mediante `context.read<AuthRepository>()`.

### Ejemplos de Código

#### Inyección en Constructor de Cubit

```dart
// /lib/cubits/auth_cubit/auth_cubit.dart:8-18
class AuthCubit extends Cubit<FirebaseAuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    final user = authRepository.currentUser;
    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(AuthInitial());
    }
  }
}
```

`AuthCubit` recibe `AuthRepository` mediante constructor injection. No crea su propia instancia, sino que depende de que se le inyecte.

**Ventajas**:
1. **Testeable**: En tests, puedes inyectar un `MockAuthRepository`
2. **Flexible**: Puedes cambiar implementaciones sin modificar `AuthCubit`
3. **Explícito**: Las dependencias son claras en la firma del constructor

#### Uso en Widgets

En `AuthPage`, se accede al Cubit para ejecutar acciones:

```dart
// En AuthPage
onPressed: () {
  // Lee AuthCubit del árbol y ejecuta login
  context.read<AuthCubit>().login(email, password);
}
```

No necesita crear `AuthCubit` ni `AuthRepository`. Simplemente usa lo que ya está disponible en el árbol.

### Especificaciones Técnicas

#### InheritedWidget: El Mecanismo Subyacente

`RepositoryProvider` y `BlocProvider` internamente usan `InheritedWidget`, un widget especial de Flutter que permite que datos fluyan eficientemente hacia abajo en el árbol de widgets.

Cuando llamas a `context.read<T>()`, Flutter recorre el árbol hacia arriba buscando el `InheritedWidget` más cercano que provea tipo `T`.

```
Widget Tree          Lookup Flow

MaterialApp          ↑
├─ Provider<A>       ← 3. Encuentra Provider<A>
│  └─ Page           ↑
│     └─ Column      ↑
│        └─ Button   ← 1. context.read<A>() llamado aquí
│                    ↑
└─ OtherPage         ← 2. Recorre árbol hacia arriba
```

#### Optimización de Rendimiento

**RepositoryProvider**:
- No escucha cambios (repositories son stateless)
- No reconstruye widgets cuando se accede
- Ideal para servicios que no manejan estado de UI

**BlocProvider**:
- Puede escuchar cambios (Cubits manejan estado)
- `context.watch()` reconstruye solo widgets que escuchan
- `BlocBuilder` optimiza reconstrucciones mediante `buildWhen`

```dart
BlocBuilder<AuthCubit, FirebaseAuthState>(
  buildWhen: (previous, current) {
    // Solo reconstruye si cambió de loading a success/failure
    return previous is AuthLoading && current is! AuthLoading;
  },
  builder: (context, state) => ...
)
```

### Mejores Prácticas

1. **Provea dependencias en el nivel más alto apropiado**

```dart
// Bueno: AuthRepository usado globalmente
MaterialApp(
  child: RepositoryProvider<AuthRepository>(...)
)

// Mejor: CortesService solo usado en HomePage
HomePage(
  child: RepositoryProvider<CortesService>(...)
)
```

2. **Use context.read() en callbacks, context.watch() en build()**

```dart
// Correcto
Widget build(BuildContext context) {
  final state = context.watch<AuthCubit>().state;  // ✓

  return ElevatedButton(
    onPressed: () {
      context.read<AuthCubit>().logout();  // ✓
    },
  );
}

// Incorrecto
void initState() {
  context.watch<AuthCubit>();  // ✗ Error: no se re-ejecuta initState
}
```

3. **Prefiera MultiRepositoryProvider para múltiples providers**

```dart
// Bueno
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<AuthRepository>(...),
    RepositoryProvider<CortesService>(...),
    RepositoryProvider<NotesService>(...),
  ],
  child: ...
)

// Malo (anidación profunda)
RepositoryProvider<AuthRepository>(
  child: RepositoryProvider<CortesService>(
    child: RepositoryProvider<NotesService>(
      child: ...
    )
  )
)
```

4. **Inyecte abstracciones, no implementaciones concretas**

Si tu aplicación crece, usa interfaces:

```dart
abstract class AuthRepositoryInterface {
  Future<User?> login(String email, String password);
}

class FirebaseAuthRepository implements AuthRepositoryInterface {
  // Implementación con Firebase
}

class MockAuthRepository implements AuthRepositoryInterface {
  // Implementación para tests
}

// Inyectar
RepositoryProvider<AuthRepositoryInterface>(
  create: (_) => FirebaseAuthRepository(),
)

// AuthCubit depende de la abstracción
class AuthCubit {
  final AuthRepositoryInterface authRepository;
}
```

5. **Cierre recursos en dispose**

Los `BlocProvider` automáticamente llaman `close()` en Cubits, pero para providers personalizados:

```dart
class MyProvider extends StatefulWidget {
  @override
  _MyProviderState createState() => _MyProviderState();
}

class _MyProviderState extends State<MyProvider> {
  late final MyService service;

  @override
  void initState() {
    super.initState();
    service = MyService();
  }

  @override
  void dispose() {
    service.dispose();  // Limpiar recursos
    super.dispose();
  }
}
```

### Desafíos Comunes

#### 1. "Provider not found" Error

```
Error: Could not find the correct Provider<AuthCubit> above this Widget
```

**Causa**: Intentando acceder a un provider que no existe en el árbol superior

**Solución**: Asegurarse que el provider está arriba en el árbol
```dart
// Incorrecto: intenta usar AuthCubit antes de ser provisto
BlocProvider<AuthCubit>(
  create: (context) => AuthCubit(),
  child: SomeWidget(
    onTap: () {
      // Error: BlocProvider aún no está montado
      context.read<AuthCubit>();
    }
  )
)

// Correcto: usa Builder para obtener nuevo context
BlocProvider<AuthCubit>(
  create: (context) => AuthCubit(),
  child: Builder(
    builder: (context) {
      // Ahora context incluye BlocProvider
      return SomeWidget(
        onTap: () => context.read<AuthCubit>()
      );
    }
  )
)
```

#### 2. Usar context.watch() fuera de build()

```dart
// Error
void initState() {
  super.initState();
  final cubit = context.watch<AuthCubit>();  // ✗ Crash
}

// Correcto
void initState() {
  super.initState();
  final cubit = context.read<AuthCubit>();  // ✓
}
```

#### 3. Crear múltiples instancias accidentalmente

```dart
// Incorrecto: crea nueva instancia cada reconstrucción
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => AuthCubit(...),  // Nueva instancia en cada build
    child: ...
  );
}

// Correcto: crear en StatefulWidget.initState o fuera de build
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = AuthCubit(...);  // Crear una vez
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authCubit,  // Reutilizar instancia existente
      child: ...
    );
  }
}
```

#### 4. Dependencias circulares

```dart
// Problema: A necesita B, B necesita A
class ServiceA {
  ServiceA(ServiceB b);
}

class ServiceB {
  ServiceB(ServiceA a);
}
```

**Solución**: Rediseñar arquitectura o usar lazy initialization

## Referencias

### Documentación Interna
- [App Architecture Overview](/docs/architecture/01-app-architecture-overview.md) - Rol de DI en la arquitectura de tres capas
- [BLoC Pattern Fundamentals](/docs/bloc-pattern/01-bloc-pattern-fundamentals.md) - Cómo DI alimenta el patrón BLoC
- [Services and Repositories](/docs/firebase/04-services-and-repositories.md) - Servicios que se inyectan

### Referencias Externas
1. Martin, R. C. (2017). "Clean Architecture: A Craftsman's Guide to Software Structure and Design". Prentice Hall. Chapter 11: DIP - The Dependency Inversion Principle.
2. Fowler, M. (2004). "Inversion of Control Containers and the Dependency Injection pattern". https://martinfowler.com/articles/injection.html
3. Flutter BLoC Library (2024). "Provider Package Documentation". https://pub.dev/packages/provider
4. Flutter BLoC Library (2024). "flutter_bloc Package Documentation". https://pub.dev/packages/flutter_bloc
5. Google Flutter Team (2024). "InheritedWidget class". https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html
6. Soares, P. (2021). "Flutter Complete Reference". Alberto Miola. Chapter 12: State Management with Provider and BLoC.

## Lecturas Adicionales

- [BLoC in NeuroAnatomía App](/docs/bloc-pattern/03-bloc-in-neuroanatomy-app.md) - Uso práctico de DI con Cubits
- [Data Flow](/docs/architecture/03-data-flow.md) - Cómo DI facilita flujo de datos limpio
- [Async Programming](/docs/technical/01-async-programming.md) - Servicios asíncronos inyectados en Cubits
