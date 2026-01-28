# Navegación y Routing en Flutter

> **Nivel**: Intermedio
> **Prerrequisitos**: Widgets básicos, Material Design, conceptos de Stack (pila)
> **Tiempo de lectura**: 18 minutos

## Introducción

Imagina que estás leyendo un libro. Cuando terminas el capítulo 1, volteas la página para leer el capítulo 2. Si quieres volver al capítulo 1, simplemente volteas la página hacia atrás. Algunas veces, usas un marcador para saltar directamente a tu capítulo favorito sin pasar por todos los anteriores.

La navegación en Flutter funciona de manera similar. Tu aplicación tiene diferentes "páginas" (llamadas screens o routes), y puedes:

- **Avanzar** a una nueva página (como voltear la página del libro)
- **Regresar** a la página anterior (como voltear hacia atrás)
- **Saltar** a una página específica (como usar un marcador)

Flutter maneja esto con algo llamado `Navigator`, que funciona como una pila de cartas:

1. Cuando abres una nueva página, la colocas encima de la pila (push)
2. Cuando cierras la página actual, la quitas de la pila (pop)
3. La página que ves siempre es la que está arriba de la pila

En esta aplicación de neuroanatomía, la navegación es fundamental:

- Comienzas en la página de autenticación (`AuthPage`)
- Después de iniciar sesión, navegas a la página principal (`HomePage`)
- Desde ahí, puedes navegar a la página de diagramas (`DiagramasPage`)
- Cuando terminas de ver los diagramas, regresas a la página principal

Todo esto se maneja con `Navigator.push()` y `Navigator.pop()`, que agregan y quitan páginas de la pila.

---

## Documentación Técnica Formal

### Fundamento Teórico

La navegación en Flutter se basa en el patrón de diseño **Stack** (pila LIFO - Last In, First Out). El `Navigator` widget mantiene una pila de objetos `Route`, donde cada `Route` representa una pantalla completa en la aplicación.

**Conceptos fundamentales:**

1. **Route**: Representa una pantalla o página en la aplicación
2. **Navigator**: Widget que gestiona una pila de Routes
3. **MaterialPageRoute**: Implementación de Route con transiciones Material Design
4. **Navigator 1.0 vs Navigator 2.0**: Dos APIs diferentes para navegación (esta app usa Navigator 1.0)

### Implementación en la Aplicación NeuroAnatomía

#### Navegación Basada en Estado de Autenticación

La aplicación implementa navegación condicional basada en el estado de autenticación:

```dart
// /lib/main.dart, líneas 40-66
BlocBuilder<AuthCubit, FirebaseAuthState>(
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
})
```

**Flujo de navegación:**
1. **AuthInitial/AuthLoading/AuthFailure**: Muestra `AuthPage` (pantalla de login)
2. **AuthSuccess**: Muestra un `Navigator` que renderiza `HomePage`
3. **Otros estados**: Muestra indicador de carga

Este patrón asegura que:
- Usuarios no autenticados no pueden acceder a `HomePage`
- La transición es automática cuando cambia el estado de autenticación
- No se usa `Navigator.push()` para la pantalla principal (se reemplaza el widget raíz)

#### Navigator.push(): Navegación Imperativa

Para navegar a la página de diagramas, se usa `Navigator.push()`:

```dart
// /lib/pages/home_page/home_page.dart, líneas 64-68
onSelected: (value) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return DiagramasPage(type: value);
  }));
}
```

**Anatomía del push:**
1. `Navigator.of(context)`: Obtiene el Navigator más cercano en el árbol de widgets
2. `.push()`: Agrega una nueva Route a la pila
3. `MaterialPageRoute`: Crea una Route con transiciones Material Design
4. `builder`: Función que construye el widget de la nueva página

#### MaterialPageRoute: Transiciones con Material Design

`MaterialPageRoute` proporciona transiciones animadas nativas de cada plataforma:

```dart
MaterialPageRoute(
  builder: (context) => const HomePage(),
)
```

**Características:**
- **Android**: Transición de deslizamiento hacia arriba (slide up)
- **iOS**: Transición de deslizamiento desde la derecha (slide from right)
- **Animación automática**: No necesitas definir animaciones manualmente
- **Gestión de estado**: Mantiene el estado de la página anterior

#### Navigator.pop(): Regresar a la Página Anterior

Aunque no se muestra explícitamente en el código, `Navigator.pop()` se invoca automáticamente cuando:

1. El usuario presiona el botón de "atrás" del sistema
2. Se desliza desde el borde izquierdo en iOS (gesto de retroceso)
3. Se llama explícitamente `Navigator.pop(context)`

```dart
// Ejemplo de uso explícito (no presente en el código actual)
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => Navigator.of(context).pop(),
)
```

**Pop con valor de retorno:**
```dart
// Página A: espera un resultado
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => PageB()),
);

// Página B: retorna un resultado
Navigator.pop(context, 'resultado');
```

#### Navigator.of(context): Acceso al Navigator

`Navigator.of(context)` busca el Navigator más cercano en el árbol de widgets:

```dart
Navigator.of(context).push(...)
```

**Alternativa con método estático:**
```dart
Navigator.push(context, ...)  // Equivalente
```

La diferencia es sutil pero importante:
- `Navigator.of(context).push()`: Método de instancia, permite personalización
- `Navigator.push()`: Método estático, más conciso

#### onGenerateInitialRoutes: Rutas Iniciales

Para casos especiales como deep linking o restauración de estado:

```dart
// /lib/main.dart, líneas 46-53
Navigator(
  onGenerateInitialRoutes: (navigator, initialRoute) {
    return [
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    ];
  },
)
```

Esta función permite:
- Definir múltiples rutas iniciales (útil para deep linking)
- Personalizar la pila de navegación al inicio
- Implementar lógica condicional para la ruta inicial

#### Patrón de Navegación con Tipos Enum

La aplicación usa un enum para tipos de diagramas, facilitando navegación type-safe:

```dart
// /lib/pages/home_page/home_page.dart, líneas 55-68
PopupMenuButton<DiagramaType>(
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
)
```

**Ventajas:**
- Type safety: El compilador verifica que `value` es un `DiagramaType`
- Autocomplete: El IDE sugiere valores válidos
- Refactoring seguro: Cambiar el enum actualiza todos los usos

### Especificaciones Técnicas

#### Stack de Navegación

El Navigator mantiene una pila de Routes internamente:

```
┌─────────────────┐
│  DiagramasPage  │  <- Top (visible)
├─────────────────┤
│    HomePage     │
├─────────────────┤
│    AuthPage     │  <- Bottom
└─────────────────┘
```

Operaciones:
- `push()`: Agrega en el tope
- `pop()`: Remueve del tope
- `replace()`: Reemplaza el tope
- `pushReplacement()`: Hace push y pop del anterior en una operación

#### Ciclo de Vida de una Route

1. **Created**: La route se crea con `MaterialPageRoute(builder: ...)`
2. **Installed**: Se agrega al Navigator con `push()`
3. **Pushed**: Animación de entrada comienza
4. **Active**: Route es visible y puede interactuar
5. **Popping**: Usuario inicia pop (botón atrás, gesto)
6. **Popped**: Animación de salida comienza
7. **Disposed**: Route se destruye y libera recursos

#### Transiciones y Animaciones

`MaterialPageRoute` usa diferentes transiciones según la plataforma:

**Android (Material)**:
```dart
// Transición vertical de abajo hacia arriba
SlideTransition(
  position: Tween(
    begin: Offset(0.0, 1.0),
    end: Offset.zero,
  ).animate(animation),
  child: child,
)
```

**iOS (Cupertino)**:
```dart
// Transición horizontal de derecha a izquierda
SlideTransition(
  position: Tween(
    begin: Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(animation),
  child: child,
)
```

#### WillPopScope: Interceptar Pop

Para confirmar antes de salir de una página:

```dart
WillPopScope(
  onWillPop: () async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Salir'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  },
  child: YourPage(),
)
```

### Mejores Prácticas

1. **Usa rutas nombradas para aplicaciones grandes**:
   ```dart
   MaterialApp(
     routes: {
       '/': (context) => HomePage(),
       '/diagrams': (context) => DiagramasPage(),
       '/quiz': (context) => QuizPage(),
     },
     initialRoute: '/',
   )

   // Navegación
   Navigator.pushNamed(context, '/diagrams');
   ```

2. **Espera resultados con async/await**:
   ```dart
   final result = await Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => DetailPage()),
   );

   if (result != null) {
     // Usar el resultado
   }
   ```

3. **Usa pushReplacement para flujos de login**:
   ```dart
   // Después de login exitoso, reemplazar AuthPage
   Navigator.pushReplacement(
     context,
     MaterialPageRoute(builder: (context) => HomePage()),
   );
   ```

4. **Limpia la pila con pushAndRemoveUntil**:
   ```dart
   // Volver a home y limpiar toda la pila
   Navigator.pushAndRemoveUntil(
     context,
     MaterialPageRoute(builder: (context) => HomePage()),
     (route) => false,  // Remueve todas las rutas anteriores
   );
   ```

5. **Pasa argumentos de forma type-safe**:
   ```dart
   // Definir clase de argumentos
   class DiagramPageArgs {
     final DiagramaType type;
     DiagramPageArgs(this.type);
   }

   // Navegar
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => DiagramasPage(
         type: DiagramaType.vias,
       ),
     ),
   );
   ```

6. **Usa Navigator 2.0 para deep linking complejo**:
   - Navigator 1.0 (usado en esta app): Imperativo, simple
   - Navigator 2.0: Declarativo, mejor para deep linking y web

### Desafíos Comunes

#### Problema: "Navigator operation requested with a context that does not include a Navigator"

**Causa**: Intentar navegar antes de que MaterialApp se construya

**Solución**:
```dart
// Mal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Navigator.push(...);  // ❌ No hay Navigator aún
    return MaterialApp(...);
  }
}

// Bien
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => Navigator.push(...),  // ✅ MaterialApp ya existe
      ),
    );
  }
}
```

#### Problema: Estado se pierde después de pop

**Causa**: El widget se reconstruye y pierde estado local

**Solución**: Pasar datos de vuelta con pop
```dart
// Página B
Navigator.pop(context, updatedData);

// Página A
final result = await Navigator.push(...);
setState(() {
  _data = result;
});
```

#### Problema: Multiple Navigator contexts causan confusión

**Causa**: Múltiples Navigators en el árbol (ej: NavigationBar)

**Solución**: Usar `Navigator.of(context, rootNavigator: true)` para acceder al Navigator raíz
```dart
Navigator.of(context, rootNavigator: true).push(...)
```

#### Problema: Animaciones personalizadas no funcionan

**Causa**: MaterialPageRoute usa animaciones predeterminadas

**Solución**: Usar `PageRouteBuilder` para animaciones personalizadas
```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NewPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

## Referencias

### Documentación Interna
- [Material Design](/docs/ui-ux/01-material-design.md) - MaterialPageRoute usa transiciones Material
- [Arquitectura de la App](/docs/architecture/01-app-architecture-overview.md) - Flujo de navegación general
- [BLoC Pattern](/docs/bloc-pattern/01-bloc-pattern-fundamentals.md) - Navegación basada en estado

### Referencias Externas

1. **Flutter Navigation and Routing**
   - https://docs.flutter.dev/ui/navigation
   - Guía oficial de navegación

2. **Navigator API Documentation**
   - https://api.flutter.dev/flutter/widgets/Navigator-class.html
   - Documentación completa de la clase Navigator

3. **Navigator 2.0 and Router**
   - https://docs.flutter.dev/ui/navigation/deep-linking
   - Sistema de navegación declarativo

4. **MaterialPageRoute Documentation**
   - https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
   - Detalles de transiciones Material

### Bibliografía Académica

- Windmill, E. (2020). *Flutter in Action*. Manning Publications. (Capítulo 7: Navigation and Routing)
- Moroney, L., & Windmill, E. (2019). *Beginning Flutter*. Wiley. (Capítulo 6: Navigation)
- Soares, P. (2021). *Flutter Complete Reference*. Alberto Miola. (Sección: Navigation System)

## Lecturas Adicionales

**Siguiente**: [Componentes Interactivos](/docs/ui-ux/04-interactive-components.md) - Manejo de interacciones de usuario

**Relacionado**:
- [Autenticación con Firebase](/docs/firebase/02-firebase-authentication.md) - Navegación basada en estado de auth
- [Flujo de Datos](/docs/architecture/03-data-flow.md) - Cómo los datos fluyen entre páginas
