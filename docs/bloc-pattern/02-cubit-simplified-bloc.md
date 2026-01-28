# Cubit: BLoC Simplificado

> **Nivel**: Intermedio
> **Prerrequisitos**: Fundamentos del Patrón BLoC
> **Tiempo de lectura**: 12 minutos

## Introducción

Si BLoC es como un restaurante con meseros que toman pedidos escritos (eventos) y los llevan a la cocina, Cubit es como llamar directamente al chef y decirle "necesito una pizza margarita". En lugar de escribir un pedido formal (crear un objeto Event), simplemente llamas a un método específico. El resultado es el mismo - recibes comida (un nuevo estado) - pero el proceso es mucho más directo y simple.

Cubit es una simplificación del patrón BLoC que elimina la necesidad de definir eventos explícitos. En lugar de crear clases de eventos y manejar la transformación de eventos a estados, con Cubit simplemente expones métodos que emiten estados directamente.

### ¿Por qué Cubit en lugar de BLoC completo?

Imagina que necesitas implementar un contador simple. Con BLoC tradicional necesitarías:
- Una clase base de eventos
- Un evento para incrementar
- Un evento para decrementar
- Un BLoC que transforme esos eventos en estados

Con Cubit solo necesitas:
- Una clase Cubit
- Dos métodos: `increment()` y `decrement()`

Para muchos casos de uso, especialmente cuando la lógica es sencilla, Cubit proporciona el 90% de los beneficios de BLoC con mucho menos código. Es perfecto para:
- Formularios y validaciones
- Autenticación
- Carga de datos desde APIs
- Gestión de estado de UI (mostrar/ocultar elementos)

### Cubit vs BLoC: ¿Cuándo usar cada uno?

**Usa Cubit cuando**:
- La lógica es relativamente simple
- No necesitas rastrear el historial de cambios
- Los métodos directos son suficientes para describir las acciones

**Usa BLoC completo cuando**:
- Necesitas tracking detallado de eventos (útil para debugging)
- Quieres aplicar transformaciones complejas (debounce, throttle)
- La traceabilidad de eventos es importante para tu caso de uso
- Necesitas reproducir secuencias de eventos (útil para tests)

En la aplicación NeuroAnatomía, usamos Cubit porque la mayoría de nuestras operaciones son directas: cargar datos, hacer login, generar un quiz. No necesitamos el overhead de eventos explícitos.

### Anatomía de un Cubit

Un Cubit es como una máquina de estados: tiene un estado actual y métodos que lo cambian. Cada vez que llamas a `emit()`, todos los widgets que están escuchando se enteran y se reconstruyen con el nuevo estado.

```dart
// Estado inicial: 0
// Usuario llama increment() → emit(1) → UI muestra 1
// Usuario llama increment() → emit(2) → UI muestra 2
```

La clave es que el estado siempre fluye en una dirección: del Cubit hacia la UI. La UI nunca modifica el estado directamente.

---

## Documentación Técnica Formal

### Fundamento Teórico

Cubit es una especialización del patrón BLoC introducida por Felix Angelov en la biblioteca `flutter_bloc`. Mientras que BLoC tradicional utiliza un flujo explícito de eventos (`Stream<Event> → BLoC → Stream<State>`), Cubit simplifica este modelo exponiendo métodos públicos que emiten estados directamente.

**Definición formal**: Un Cubit es una clase que extiende `Cubit<State>` y gestiona un stream de estados mediante el método `emit()`.

```dart
class SimpleCubit extends Cubit<StateType> {
  SimpleCubit() : super(initialState);

  void performAction() {
    // Lógica de negocio
    emit(newState); // Emite nuevo estado
  }
}
```

### Implementación en la Aplicación NeuroAnatomía

La aplicación utiliza Cubit como su mecanismo principal de gestión de estado. Examinaremos `AuthCubit` como ejemplo canónico de implementación.

#### AuthCubit: Ejemplo Completo

**Archivo**: `/lib/cubits/auth_cubit/auth_cubit.dart`

```dart
class AuthCubit extends Cubit<FirebaseAuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    // Constructor: verifica si hay usuario autenticado
    final user = authRepository.currentUser;
    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading(email: email, password: password));
    try {
      final user = await authRepository.login(email, password);
      if (user != null) emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
```

**Análisis línea por línea**:

- **Líneas 1-4**: `AuthCubit` extiende `Cubit<FirebaseAuthState>`, donde `FirebaseAuthState` es el tipo base de todos los estados posibles
- **Línea 5**: Inyección de dependencias - el `AuthRepository` se inyecta para acceder a Firebase Auth
- **Líneas 7-14**: Constructor con lógica de inicialización - verifica si existe una sesión activa al crear el Cubit
- **Líneas 16-24**: Método `login()` - maneja el flujo de autenticación completo con estados intermedios
- **Líneas 64-71**: Método `logout()` - cierra sesión y resetea al estado inicial

### Clases de Estado con Equatable

**Archivo**: `/lib/cubits/auth_cubit/auth_state.dart`

```dart
abstract class FirebaseAuthState extends Equatable {
  const FirebaseAuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends FirebaseAuthState {}

class AuthLoading extends FirebaseAuthState {
  final String email;
  final String password;

  const AuthLoading({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSuccess extends FirebaseAuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthFailure extends FirebaseAuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}
```

#### ¿Por qué Equatable?

`Equatable` es un paquete que simplifica la comparación de objetos en Dart. Sin Equatable, dos instancias de `AuthLoading` con los mismos valores serían consideradas diferentes, causando reconstrucciones innecesarias de widgets.

**Problema sin Equatable**:
```dart
AuthLoading(email: "test@test.com") == AuthLoading(email: "test@test.com") // false
```

**Solución con Equatable**:
```dart
// Al override props, Equatable compara los valores
AuthLoading(email: "test@test.com") == AuthLoading(email: "test@test.com") // true
```

`BlocBuilder` usa comparación de estados para determinar si debe reconstruir. Con Equatable, solo se reconstruye cuando los valores realmente cambian.

### Máquina de Estados: AuthCubit

El AuthCubit implementa una máquina de estados finitos con las siguientes transiciones:

```
AuthInitial
    ↓ (usuario llama login)
AuthLoading
    ↓ (éxito)
AuthSuccess
    ↓ (usuario llama logout)
AuthInitial

AuthLoading
    ↓ (error)
AuthFailure
    ↓ (usuario reintenta)
AuthLoading
```

**Características de la máquina de estados**:
- **Estado inicial**: `AuthInitial` - sin usuario autenticado
- **Estados intermedios**: `AuthLoading` - operación en progreso
- **Estados finales**: `AuthSuccess` (éxito) o `AuthFailure` (error)
- **Transiciones determinísticas**: Cada método define claramente qué estados puede emitir

### Operaciones Asíncronas en Cubit

Los métodos de Cubit frecuentemente son asíncronos (`async`/`await`) porque interactúan con servicios externos:

```dart
Future<void> login(String email, String password) async {
  emit(AuthLoading(email: email, password: password)); // Estado inmediato
  try {
    final user = await authRepository.login(email, password); // Espera async
    if (user != null) emit(AuthSuccess(user: user)); // Éxito
  } catch (e) {
    emit(AuthFailure(message: e.toString())); // Error
  }
}
```

**Flujo de estados**:
1. `emit(AuthLoading)` - inmediato, muestra spinner en UI
2. `await authRepository.login()` - espera respuesta de Firebase
3. `emit(AuthSuccess/AuthFailure)` - basado en resultado

Este patrón de tres estados (Loading → Success/Failure) es extremadamente común en aplicaciones que consumen APIs.

### Manejo de Errores

AuthCubit implementa manejo de errores mediante bloques `try-catch`:

```dart
try {
  final user = await authRepository.login(email, password);
  if (user != null) emit(AuthSuccess(user: user));
} catch (e) {
  emit(AuthFailure(message: e.toString())); // Captura cualquier excepción
}
```

**Ventajas de este enfoque**:
- Todos los errores (red, Firebase, validación) son capturados
- El estado `AuthFailure` contiene el mensaje de error para mostrarlo en UI
- La aplicación nunca crashea por errores de autenticación
- Debugging simplificado - el mensaje de error está en el estado

### Ejemplo de Uso en UI

**Integración con BlocBuilder** (patrón común en la app):

```dart
BlocBuilder<AuthCubit, FirebaseAuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }

    if (state is AuthFailure) {
      return Text('Error: ${state.message}');
    }

    if (state is AuthSuccess) {
      return Text('Welcome ${state.user.displayName}');
    }

    // AuthInitial - mostrar formulario de login
    return LoginForm(
      onSubmit: (email, password) {
        context.read<AuthCubit>().login(email, password);
      },
    );
  },
)
```

**Funcionamiento**:
1. `BlocBuilder` se suscribe al stream de estados de `AuthCubit`
2. Cada vez que `AuthCubit` emite un estado, se llama al builder
3. El builder renderiza UI diferente según el tipo de estado
4. `context.read<AuthCubit>()` obtiene la instancia del Cubit para llamar métodos

### Especificaciones Técnicas

#### Lifecycle de un Cubit

1. **Creación**: Constructor inicializa el estado inicial
2. **Emisión**: Métodos llaman a `emit()` para cambiar estado
3. **Suscripción**: Widgets se suscriben al stream interno
4. **Disposición**: `close()` cierra el stream (automático con BlocProvider)

#### Type Safety

Cubit proporciona type safety completo:
```dart
Cubit<int> counterCubit; // Solo puede emitir enteros
Cubit<FirebaseAuthState> authCubit; // Solo puede emitir estados de auth
```

El compilador de Dart valida que solo emitas estados del tipo correcto.

#### Inmutabilidad de Estados

Los estados deben ser inmutables para garantizar predictibilidad:

```dart
// ✅ Correcto - Estado inmutable
class AuthSuccess extends FirebaseAuthState {
  final User user; // final = inmutable
  const AuthSuccess({required this.user});
}

// ❌ Incorrecto - Estado mutable
class AuthSuccess extends FirebaseAuthState {
  User user; // sin final = mutable
  AuthSuccess({required this.user});
}
```

**Razón**: Si los estados fueran mutables, podrías modificar `state.user.name` sin llamar a `emit()`, y BlocBuilder no se enteraría del cambio.

### Mejores Prácticas

1. **Estados inmutables**: Usar `const`, `final`, y `@immutable`
2. **Equatable para comparación**: Implementar `props` correctamente
3. **Nombres descriptivos**: `login()` no `doAuth()`, `AuthSuccess` no `State2`
4. **Un Cubit por característica**: No crear mega-cubits que hacen todo
5. **Inyección de dependencias**: Pasar repositories/services por constructor
6. **Manejo de errores**: Siempre usar try-catch en operaciones async
7. **Estados de carga**: Emitir estado Loading antes de operaciones async

### Comparación: Cubit vs setState

| Característica | setState | Cubit |
|---------------|----------|-------|
| Scope | Widget local | Global/compartido |
| Testabilidad | Difícil | Fácil |
| Reutilización | No | Sí |
| Separación lógica/UI | No | Sí |
| Código boilerplate | Mínimo | Moderado |
| Curva de aprendizaje | Baja | Media |

### Desafíos Comunes

#### 1. Estado no se actualiza en UI
**Causa**: BlocBuilder no está envolviendo el widget que debe cambiar
**Solución**: Asegurar que BlocBuilder esté en el nivel correcto del árbol

#### 2. Emisión después de close
**Causa**: Llamar `emit()` después de `close()` lanza excepción
**Solución**: Verificar `isClosed` antes de emitir en operaciones async

```dart
Future<void> loadData() async {
  final data = await fetchData();
  if (!isClosed) {  // Verificación importante
    emit(DataLoaded(data));
  }
}
```

#### 3. Estados idénticos no actualizan UI
**Causa**: No implementar Equatable correctamente
**Solución**: Incluir todos los campos en `props`

## Referencias

### Documentación Interna
- [Fundamentos del Patrón BLoC](./01-bloc-pattern-fundamentals.md)
- [BLoC en la Aplicación NeuroAnatomía](./03-bloc-in-neuroanatomy-app.md) - Siguiente lectura
- [Flujo de Datos](/docs/architecture/03-data-flow.md)

### Referencias Externas
1. Angelov, F. (2020). "Cubit vs Bloc". BLoC Library Documentation. https://bloclibrary.dev/#/coreconcepts?id=cubit-vs-bloc
2. BLoC Library - Cubit Documentation. https://bloclibrary.dev/#/coreconcepts?id=cubit
3. Equatable Package Documentation. https://pub.dev/packages/equatable
4. Dart Language - Asynchronous Programming. https://dart.dev/codelabs/async-await
5. Soares, P. (2021). *Flutter Complete Reference*. Alberto Miola. (Capítulo sobre State Management)

## Lecturas Adicionales

**Siguiente paso**: Lee [BLoC en la Aplicación NeuroAnatomía](./03-bloc-in-neuroanatomy-app.md) para ver todos los Cubits implementados en el proyecto.

**Temas avanzados**:
- Testing de Cubits con `bloc_test`
- Monitoreo de transiciones con `BlocObserver`
- Transformaciones de eventos en BLoC completo
- Patrones de composición de Cubits
