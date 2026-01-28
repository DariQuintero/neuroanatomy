# Widgets Reutilizables

> **Nivel**: Intermedio
> **Prerrequisitos**: StatelessWidget, StatefulWidget, composición de widgets
> **Tiempo de lectura**: 25 minutos

## Introducción

Imagina que estás cocinando y tienes recetas favoritas que usas una y otra vez: tu salsa especial, tu masa para pizza perfecta, tu aderezo secreto. En lugar de seguir el mismo proceso desde cero cada vez, ya tienes la receta memorizada y solo necesitas replicarla.

Los widgets reutilizables en Flutter funcionan igual. Son componentes de UI que creas una vez y luego usas en múltiples lugares de tu aplicación. En lugar de escribir el mismo código repetidamente, defines el widget una vez y lo reutilizas donde lo necesites.

**Beneficios de widgets reutilizables:**

1. **Consistencia**: Todos los botones, campos de entrada, o cards se ven y comportan igual
2. **Mantenibilidad**: Si necesitas cambiar algo, lo cambias en un solo lugar
3. **Productividad**: Escribes menos código y trabajas más rápido
4. **Testing**: Puedes probar un componente aisladamente

En esta aplicación de neuroanatomía, tenemos tres widgets reutilizables principales:

- **LoadingButton**: Un botón que muestra un indicador de carga cuando está procesando
- **InteractiveIlustracion**: Una ilustración del cerebro con regiones clickeables
- **DragIndicator**: Un pequeño indicador visual para paneles deslizables

Cada uno de estos widgets se define una vez y se usa en múltiples contextos, haciendo que el código sea más limpio y mantenible.

---

## Documentación Técnica Formal

### Fundamento Teórico

La composición de widgets es un patrón fundamental en Flutter, basado en el principio de "composition over inheritance" (composición sobre herencia). En lugar de crear jerarquías de clases complejas, Flutter favorece la composición de widgets pequeños y enfocados.

**Principios de diseño de widgets reutilizables:**

1. **Single Responsibility**: Cada widget debe tener una responsabilidad clara
2. **Configurabilidad**: Permitir personalización mediante parámetros
3. **Encapsulación**: Ocultar detalles de implementación
4. **Composición**: Combinar widgets simples para crear widgets complejos

### Implementación en la Aplicación NeuroAnatomía

#### 1. DragIndicator: Widget Reutilizable Simple

El widget más simple es `DragIndicator`, un indicador visual para paneles deslizables:

```dart
// /lib/widgets/drag_indicator.dart, líneas 1-17
import 'package:flutter/material.dart';

class DragIndicator extends StatelessWidget {
  const DragIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
```

**Características:**
- **StatelessWidget**: No tiene estado interno mutable
- **Sin parámetros**: Siempre se ve igual (no es configurable)
- **Diseño simple**: Solo un Container con decoración
- **Reutilizable**: Puede usarse en cualquier panel deslizable

**Uso:**
```dart
// En cualquier parte de la aplicación
SlidingUpPanel(
  panel: Column(
    children: [
      DragIndicator(),
      // ... resto del contenido
    ],
  ),
)
```

#### 2. LoadingButton: Widget Configurable con Estado

`LoadingButton` es más complejo, con múltiples parámetros de configuración y animaciones:

```dart
// /lib/widgets/loading_button.dart, líneas 3-27
class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final Color? disabledColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.disabledColor,
    this.width,
    this.height = 50,
    this.borderRadius = 25,
    this.isLoading = false,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}
```

**Parámetros de configuración:**

| Parámetro | Tipo | Requerido | Default | Descripción |
|-----------|------|-----------|---------|-------------|
| `onPressed` | `VoidCallback?` | Sí | - | Callback cuando se presiona |
| `child` | `Widget` | Sí | - | Contenido del botón (texto, ícono) |
| `color` | `Color?` | No | `Theme.primaryColor` | Color del botón |
| `disabledColor` | `Color?` | No | `color` con alpha 0.5 | Color cuando está deshabilitado |
| `width` | `double?` | No | `null` (expande) | Ancho del botón |
| `height` | `double` | No | `50` | Altura del botón |
| `borderRadius` | `double` | No | `25` | Radio de bordes redondeados |
| `isLoading` | `bool` | No | `false` | Si muestra indicador de carga |

#### Estado Interno y Animaciones

El botón mantiene un `AnimationController` para la animación de escala:

```dart
// /lib/widgets/loading_button.dart, líneas 29-50
class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
```

**Componentes de animación:**
- **AnimationController**: Controla la duración y dirección de la animación
- **Tween**: Define interpolación de 1.0 a 0.95 (escala al 95%)
- **CurvedAnimation**: Aplica curva de aceleración suave
- **SingleTickerProviderStateMixin**: Proporciona ticker para animaciones

#### Manejo de Eventos Táctiles

El botón responde a diferentes eventos táctiles:

```dart
// /lib/widgets/loading_button.dart, líneas 52-68
void _handleTapDown(TapDownDetails details) {
  if (!widget.isLoading && widget.onPressed != null) {
    _controller.forward();
  }
}

void _handleTapUp(TapUpDetails details) {
  if (!widget.isLoading && widget.onPressed != null) {
    _controller.reverse();
  }
}

void _handleTapCancel() {
  if (!widget.isLoading && widget.onPressed != null) {
    _controller.reverse();
  }
}
```

**Flujo de animación:**
1. `onTapDown`: Usuario presiona → Anima a escala 0.95
2. `onTapUp`: Usuario suelta → Anima de vuelta a escala 1.0
3. `onTapCancel`: Usuario arrastra fuera → Anima de vuelta a escala 1.0

#### Widget Build con Múltiples Animaciones

```dart
// /lib/widgets/loading_button.dart, líneas 70-122
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final buttonColor = widget.color ?? theme.primaryColor;
  final isDisabled = widget.onPressed == null || widget.isLoading;

  return GestureDetector(
    onTapDown: _handleTapDown,
    onTapUp: _handleTapUp,
    onTapCancel: _handleTapCancel,
    onTap: widget.isLoading ? null : widget.onPressed,
    child: ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDisabled
              ? (widget.disabledColor ?? buttonColor.withValues(alpha: 0.5))
              : buttonColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    ),
  );
}
```

**Widgets de animación anidados:**

1. **GestureDetector**: Detecta toques y llama callbacks
2. **ScaleTransition**: Anima la escala del botón al presionarse
3. **AnimatedContainer**: Anima cambios de color y sombra
4. **AnimatedSwitcher**: Anima transición entre child y loading indicator

#### 3. InteractiveIlustracion: Widget Complejo con BLoC

El widget más complejo es `InteractiveIlustracion`:

```dart
// /lib/widgets/interactive_ilustracion.dart, líneas 10-30
class InteractiveIlustracion extends StatelessWidget {
  final CorteCerebro corteCerebro;
  final Function(SegmentoCerebro estructura)? onEstructuraTap;
  final Function(VistaCerebro vista)? onVistaTap;
  final bool showVistas;
  final List<SegmentoCerebro> highlightedSegmentos;
  final ImageMode imageMode;
  final Function(ImageMode)? onImageModeChange;
  final bool showSwitchImageMode;

  const InteractiveIlustracion({
    super.key,
    required this.corteCerebro,
    this.onEstructuraTap,
    this.onVistaTap,
    this.highlightedSegmentos = const [],
    this.showVistas = false,
    this.imageMode = ImageMode.real,
    this.onImageModeChange,
    this.showSwitchImageMode = true,
  });
```

**Parámetros avanzados:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `corteCerebro` | `CorteCerebro` | Modelo de datos del corte cerebral |
| `onEstructuraTap` | `Function(SegmentoCerebro)?` | Callback al tocar segmento |
| `onVistaTap` | `Function(VistaCerebro)?` | Callback al tocar vista |
| `showVistas` | `bool` | Si mostrar indicadores de navegación |
| `highlightedSegmentos` | `List<SegmentoCerebro>` | Segmentos a resaltar |
| `imageMode` | `ImageMode` | Modo de imagen (real/acuarela) |
| `onImageModeChange` | `Function(ImageMode)?` | Callback al cambiar modo |
| `showSwitchImageMode` | `bool` | Si mostrar botón de cambio de modo |

#### Integración con BLoC

Aunque es un `StatelessWidget`, usa BLoC para gestión de estado interno:

```dart
// /lib/widgets/interactive_ilustracion.dart, líneas 32-137
@override
Widget build(BuildContext context) {
  return BlocProvider<CorteInteractivoCubit>(
      create: (context) =>
          CorteInteractivoCubit(corte: corteCerebro)..getImages(),
      child: BlocBuilder<CorteInteractivoCubit, CorteInteractivoState>(
        builder: (context, state) {
          if (state is CorteInteractivoLoading ||
              state is CorteInteractivoInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is CorteInteractivoError) {
            return Center(
              child: Text(state.message),
            );
          }
          final readyState = (state as CorteInteractivoReady);
          return LayoutBuilder(builder: (context, constraints) {
            // ... construcción del widget
          });
        },
      ));
}
```

**Patrón de encapsulación:**
- El widget padre no necesita saber sobre la carga de imágenes
- Toda la lógica de carga está encapsulada en `CorteInteractivoCubit`
- El widget se comporta como una "caja negra" configurable

### Especificaciones Técnicas

#### Parámetros Opcionales vs Requeridos

Flutter distingue entre parámetros opcionales y requeridos:

```dart
class MyWidget extends StatelessWidget {
  // Requerido: debe proporcionarse
  final String title;

  // Opcional con default: usa default si no se proporciona
  final Color color;

  // Opcional nullable: puede ser null
  final VoidCallback? onPressed;

  const MyWidget({
    super.key,
    required this.title,           // required keyword
    this.color = Colors.blue,      // default value
    this.onPressed,                // nullable
  });
}
```

#### Default Values y Null Safety

Con null safety, hay tres patrones para valores por defecto:

**1. Default en constructor:**
```dart
final double height;
const MyWidget({this.height = 50});
```

**2. Default en build:**
```dart
final Color? color;
const MyWidget({this.color});

@override
Widget build(BuildContext context) {
  final buttonColor = color ?? Theme.of(context).primaryColor;
}
```

**3. Late initialization:**
```dart
late final Color _color;

@override
void initState() {
  super.initState();
  _color = widget.color ?? Colors.blue;
}
```

#### Widget Keys

Keys identifican widgets únicamente en el árbol:

```dart
InteractiveIlustracion(
  key: ValueKey(cortesState.selectedCorte.id),
  corteCerebro: cortesState.selectedCorte,
  // ...
)
```

**Tipos de Keys:**
- `Key()`: Key base (raramente usado directamente)
- `ValueKey(value)`: Key basada en valor
- `ObjectKey(object)`: Key basada en identidad de objeto
- `UniqueKey()`: Key única generada
- `GlobalKey()`: Key global para acceder al widget desde cualquier lugar

**Cuándo usar keys:**
- Widgets en listas que pueden reordenarse
- Widgets que se reemplazan pero mantienen estado
- Widgets que necesitan ser encontrados desde fuera

#### Callbacks y Function Types

Los widgets reutilizables usan callbacks para comunicarse con el padre:

```dart
// Callback sin parámetros
final VoidCallback? onPressed;

// Callback con parámetro
final Function(String value)? onChanged;

// Callback con tipo específico
final void Function(SegmentoCerebro)? onEstructuraTap;

// Callback con retorno
final Future<bool> Function()? onWillPop;
```

**Invocación de callbacks opcionales:**
```dart
// Opción 1: Null-aware call
onPressed?.call();

// Opción 2: If check
if (onPressed != null) {
  onPressed();
}
```

#### const Constructors

Los widgets reutilizables deben usar constructores `const` cuando sea posible:

```dart
const DragIndicator({super.key});
```

**Beneficios:**
- Flutter puede reutilizar instancias idénticas
- Mejora el rendimiento al evitar reconstrucciones innecesarias
- Reduce uso de memoria

**Requisitos para const:**
- Todos los fields deben ser `final`
- Todos los parámetros deben ser `const` o valores primitivos
- No puede tener lógica en el constructor

### Mejores Prácticas

1. **Documentar parámetros claramente**:
   ```dart
   /// A button that shows a loading indicator when processing.
   ///
   /// The [onPressed] callback is called when the button is tapped.
   /// If [isLoading] is true, the button shows a [CircularProgressIndicator].
   class LoadingButton extends StatefulWidget {
     // ...
   }
   ```

2. **Usar named parameters para configuración**:
   ```dart
   // Bien: Fácil de leer
   LoadingButton(
     onPressed: _handleSubmit,
     isLoading: _isLoading,
     child: Text('Submit'),
   )

   // Mal: Difícil de entender
   LoadingButton(_handleSubmit, _isLoading, Text('Submit'))
   ```

3. **Proporcionar defaults razonables**:
   ```dart
   const LoadingButton({
     this.height = 50,          // Default razonable
     this.borderRadius = 25,    // Default razonable
     this.isLoading = false,    // Default seguro
   });
   ```

4. **Validar parámetros en desarrollo**:
   ```dart
   const MyWidget({required this.items}) : assert(items.length > 0);
   ```

5. **Extraer widgets reutilizables cuando veas duplicación**:
   ```dart
   // Si ves esto 3+ veces
   Container(
     width: 28,
     height: 5,
     decoration: BoxDecoration(
       color: Colors.grey[300],
       borderRadius: BorderRadius.circular(12),
     ),
   )

   // Extrae a
   DragIndicator()
   ```

6. **Mantener widgets enfocados (Single Responsibility)**:
   ```dart
   // Bien: Un solo propósito
   class LoadingButton extends StatefulWidget { }

   // Mal: Múltiples propósitos
   class ButtonWithIconAndLoadingAndBadge extends StatefulWidget { }
   ```

7. **Usar composition sobre herencia**:
   ```dart
   // Bien: Composición
   class CustomCard extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Card(
         child: Padding(
           padding: EdgeInsets.all(16),
           child: child,
         ),
       );
     }
   }

   // Evitar: Herencia
   class CustomCard extends Card {
     // Complicado de mantener
   }
   ```

### Desafíos Comunes

#### Problema: Widget se reconstruye demasiado

**Causa**: Widget padre se reconstruye y reconstruye todos los hijos

**Solución**: Usar `const` constructors o extraer a widgets separados
```dart
// Mal: Se reconstruye cada vez que Parent cambia
class Parent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(color: Colors.red),  // Se reconstruye
        Container(color: Colors.blue), // Se reconstruye
      ],
    );
  }
}

// Bien: Solo se construye una vez
class Parent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        RedBox(),  // const, no se reconstruye
        BlueBox(), // const, no se reconstruye
      ],
    );
  }
}
```

#### Problema: AnimationController no se limpia

**Causa**: Olvidar llamar `dispose()`

**Solución**: Siempre limpiar en `dispose()`
```dart
@override
void dispose() {
  _controller.dispose();  // ✅ Muy importante
  super.dispose();
}
```

#### Problema: Keys causan que widgets pierdan estado

**Causa**: Usar keys inconsistentes o que cambian

**Solución**: Usar keys estables basadas en IDs únicos
```dart
// Mal: Key cambia en cada build
ListView(
  children: items.map((item) =>
    Card(key: UniqueKey(), ...)  // ❌ Nueva key cada vez
  ).toList(),
)

// Bien: Key estable
ListView(
  children: items.map((item) =>
    Card(key: ValueKey(item.id), ...)  // ✅ Key consistente
  ).toList(),
)
```

## Referencias

### Documentación Interna
- [Widgets y UI](/docs/flutter-basics/02-widgets-and-ui.md) - Fundamentos de widgets
- [Componentes Interactivos](/docs/ui-ux/04-interactive-components.md) - LoadingButton implementation
- [BLoC Pattern](/docs/bloc-pattern/01-bloc-pattern-fundamentals.md) - BLoC en widgets

### Referencias Externas

1. **Flutter Widget Catalog**
   - https://docs.flutter.dev/ui/widgets
   - Catálogo completo de widgets

2. **Creating Custom Widgets**
   - https://docs.flutter.dev/ui/widgets/intro#creating-custom-widgets
   - Guía oficial para crear widgets personalizados

3. **Keys in Flutter**
   - https://api.flutter.dev/flutter/foundation/Key-class.html
   - Documentación de Keys

4. **Best Practices for Widget Composition**
   - https://docs.flutter.dev/perf/best-practices
   - Mejores prácticas de rendimiento

### Bibliografía Académica

- Windmill, E. (2020). *Flutter in Action*. Manning Publications. (Capítulo 4: Widget Composition)
- Gamma, E., et al. (1994). *Design Patterns: Elements of Reusable Object-Oriented Software*. Addison-Wesley. (Composition Pattern)
- Martin, R. C. (2017). *Clean Architecture*. Prentice Hall. (Single Responsibility Principle)

## Lecturas Adicionales

**Siguiente**: [Painters](/docs/components/02-painters.md) - Widgets de dibujo personalizado

**Relacionado**:
- [Visualización Interactiva del Cerebro](/docs/features/01-interactive-brain-visualization.md) - Uso de InteractiveIlustracion
- [Material Design](/docs/ui-ux/01-material-design.md) - Diseño de widgets Material
