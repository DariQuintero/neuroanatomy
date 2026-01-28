# Componentes Interactivos en Flutter

> **Nivel**: Intermedio
> **Prerrequisitos**: Widgets básicos, GestureDetector, callbacks
> **Tiempo de lectura**: 22 minutos

## Introducción

Imagina un control remoto de televisión. Cada botón hace algo: cambiar de canal, subir el volumen, pausar. Cuando presionas un botón, ocurre algo. Algunos botones tienen un solo comportamiento (presionar), mientras que otros son más complejos (presionar y mantener, doble clic).

Los componentes interactivos en Flutter funcionan de la misma manera. Son widgets que responden a las acciones del usuario: toques, deslizamientos, arrastres, y más. Flutter proporciona herramientas poderosas para capturar y responder a estas interacciones.

**GestureDetector** es como un detector de movimiento invisible que puedes colocar alrededor de cualquier widget. Detecta diferentes tipos de gestos:

- **Tap**: Un toque rápido (como hacer clic)
- **Double Tap**: Dos toques rápidos
- **Long Press**: Mantener presionado
- **Pan**: Arrastrar con el dedo
- **Scale**: Pellizcar para hacer zoom
- **Swipe**: Deslizar rápidamente

En esta aplicación de neuroanatomía, las interacciones son fundamentales:

1. **Tocar regiones del cerebro**: Cuando tocas una región del cerebro, se resalta y muestra información detallada
2. **Deslizar para navegar**: Puedes navegar entre diferentes cortes del cerebro
3. **Panel deslizante**: El panel de detalles se desliza hacia arriba y abajo con tu dedo
4. **Botones con feedback visual**: Los botones muestran animaciones cuando los presionas

Todo esto se implementa con `GestureDetector`, callbacks, y widgets especializados como `SlidingUpPanel`.

---

## Documentación Técnica Formal

### Fundamento Teórico

La detección de gestos en Flutter se basa en un sistema de "gesture arena" (arena de gestos), donde múltiples detectores de gestos pueden competir para manejar un mismo evento táctil. El sistema resuelve conflictos mediante un proceso de arbitraje que determina qué gesto gana.

**Conceptos fundamentales:**

1. **Pointer Events**: Eventos de bajo nivel (down, move, up, cancel)
2. **Gesture Recognizers**: Detectores que interpretan secuencias de pointer events
3. **Gesture Arena**: Sistema de resolución de conflictos entre gestos
4. **Hit Testing**: Determinar qué widgets están bajo el punto de toque

### Implementación en la Aplicación NeuroAnatomía

#### GestureDetector para Regiones Clickeables

La ilustración interactiva usa `GestureDetector` para detectar toques en segmentos del cerebro:

```dart
// /lib/widgets/interactive_ilustracion.dart, líneas 68-91
...corteCerebro.segmentos.map((segmento) {
  return GestureDetector(
      child: CustomPaint(
        size: Size(
          width,
          width *
              (currentImage.image.height /
                  currentImage.image.width),
        ),
        painter: SegmentoPainter(
          segmento: segmento,
          isHighlighted:
              highlightedSegmentos.contains(segmento),
          cerebroSize: Size(
            currentImage.image.width.toDouble(),
            currentImage.image.height.toDouble(),
          ),
          highlightColor: Colors.green.withValues(alpha: 0.5),
        ),
      ),
      onTap: () {
        onEstructuraTap?.call(segmento);
      });
})
```

**Flujo de interacción:**
1. Usuario toca la pantalla
2. `GestureDetector` recibe el evento
3. `CustomPainter.hitTest()` verifica si el toque está dentro del path del segmento
4. Si es así, `onTap` se ejecuta
5. El callback `onEstructuraTap` notifica al widget padre
6. El padre actualiza el estado para resaltar el segmento

#### CustomPainter.hitTest(): Hit Testing Personalizado

El `SegmentoPainter` implementa hit testing personalizado para paths SVG complejos:

```dart
// /lib/painters/segmento_painter.dart, líneas 49-58
@override
bool hitTest(Offset position) {
  for (var path in scaledPaths) {
    if (path.contains(position)) {
      return true;
    }
  }
  return false;
}
```

**Proceso de hit testing:**
1. Flutter llama `hitTest()` con la posición del toque
2. Se itera sobre todos los paths escalados del segmento
3. Se usa `path.contains()` para verificar si el punto está dentro del path
4. Retorna `true` si el toque está dentro de cualquier path, `false` si no

Este método permite que formas irregulares (como regiones del cerebro) sean clickeables con precisión.

#### VistaPainter.hitTest(): Hit Testing para Líneas

Las líneas de navegación (vistas) también implementan hit testing personalizado:

```dart
// /lib/painters/vista_painter.dart, líneas 44-58
@override
bool hitTest(Offset position) {
  // the path is just a line so
  // first get the x1, y1, x2, y2 of the line
  final pathBounds = scaledPath.getBounds();
  // create a path but with small padding
  const padding = 10;
  final pathWithArea = Path()
    ..moveTo(pathBounds.left - padding, pathBounds.top - padding)
    ..lineTo(pathBounds.right + padding, pathBounds.top - padding)
    ..lineTo(pathBounds.right + padding, pathBounds.bottom + padding)
    ..lineTo(pathBounds.left - padding, pathBounds.bottom + padding)
    ..close();
  return pathWithArea.contains(position);
}
```

**Problema resuelto**: Las líneas son difíciles de tocar porque son muy delgadas

**Solución**: Crear un área rectangular alrededor de la línea con padding de 10 píxeles, haciendo que la línea sea más fácil de tocar

#### SlidingUpPanel: Panel Interactivo Deslizable

La aplicación usa el paquete `sliding_up_panel` para un panel que se desliza hacia arriba:

```dart
// /lib/pages/home_page/home_page.dart, líneas 153-196
SlidingUpPanel(
  controller: panelController,
  parallaxEnabled: true,
  parallaxOffset: 0.4,
  maxHeight: panelHeightOpen,
  minHeight: 0,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.symmetric(horizontal: 16),
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(28),
  ),
  body: Padding(
    padding: EdgeInsets.only(bottom: context.mediaQuery.size.height * 0.2),
    child: Stack(
      children: [
        _buildNavigationButtons(cortesState, context),
        _buildInteractiveIlustration(cortesState, context),
      ],
    ),
  ),
  panelBuilder: (sc) {
    final segmento = cortesState.selectedSegmento;
    return _buildPanel(
      sc,
      segmento,
      cortesState.cortes,
      cortesState.selectedCorte,
      cortesState.imageMode,
      context,
    );
  },
  onPanelSlide: (position) {
    final currentTop = panelHeightOpen * position;
    final hideFab = position > 0.5;
    setState(() {
      _fabPadding = currentTop + _initialFabHeight;
      showFab = !hideFab;
    });
  },
  onPanelClosed: () {
    context.read<CortesCubit>().selectSegmento(null);
  },
)
```

**Características del panel:**
- **Parallax**: El fondo se mueve a diferente velocidad que el panel (efecto de profundidad)
- **Controller**: Control programático del panel (`open()`, `close()`)
- **Callbacks**: `onPanelSlide` para actualizaciones durante el deslizamiento
- **Responsive**: Altura máxima basada en el tamaño de la pantalla

#### Control Programático del Panel

El panel se controla tanto por gestos del usuario como programáticamente:

```dart
// /lib/pages/home_page/home_page.dart, líneas 72-81
listener: (context, state) {
  if (state is CortesReady) {
    if (!panelController.isAttached) return;
    final selectedSegmento = state.selectedSegmento;
    if (selectedSegmento != null) {
      panelController.open();
    } else {
      panelController.close();
    }
  }
},
```

**Flujo:**
1. Usuario toca un segmento del cerebro
2. `CortesCubit` actualiza su estado con el segmento seleccionado
3. `BlocConsumer` escucha el cambio de estado
4. Automáticamente abre el panel con `panelController.open()`

#### Callback Dinámico: onPanelSlide

Durante el deslizamiento, se actualiza la posición del FAB dinámicamente:

```dart
// /lib/pages/home_page/home_page.dart, líneas 185-192
onPanelSlide: (position) {
  final currentTop = panelHeightOpen * position;
  final hideFab = position > 0.5;
  setState(() {
    _fabPadding = currentTop + _initialFabHeight;
    showFab = !hideFab;
  });
}
```

**Variables:**
- `position`: Valor de 0.0 (cerrado) a 1.0 (completamente abierto)
- `currentTop`: Posición actual del tope del panel en píxeles
- `hideFab`: `true` cuando el panel está más de 50% abierto

**Efecto**: El FAB se mueve hacia arriba con el panel y se oculta cuando el panel está medio abierto

#### LoadingButton: Botón con Animación de Escala

El `LoadingButton` personalizado responde a eventos táctiles con animaciones:

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

**Implementación del gesture detector:**

```dart
// /lib/widgets/loading_button.dart, líneas 76-120
GestureDetector(
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
)
```

**Animaciones combinadas:**
1. **ScaleTransition**: Escala el botón a 0.95 cuando se presiona
2. **AnimatedContainer**: Transición suave de colores y sombras
3. **AnimatedSwitcher**: Transición entre contenido normal e indicador de carga

#### IconButton con Transparencia Condicional

Los botones de navegación usan transparencia para indicar cuando la navegación no está disponible:

```dart
// /lib/pages/home_page/home_page.dart, líneas 199-234
Widget _buildIzquierdaButton(BuildContext context) {
  bool transparent = false;
  final state = context.read<CortesCubit>().state;
  if (state is! CortesReady) {
    transparent = true;
  }

  state as CortesReady;
  final currentCorte = state.selectedCorte;
  final izquierdaId = currentCorte.izquierdaId;
  if (izquierdaId == null) {
    transparent = true;
  }

  return IconButton(
    onPressed: () {
      final state = context.read<CortesCubit>().state;
      if (state is! CortesReady) {
        return;
      }
      final currentCorte = state.selectedCorte;
      final izquierdaId = currentCorte.izquierdaId;
      final corteTo = state.cortes.firstWhereOrNull(
        (corte) => corte.id == izquierdaId,
      );

      if (corteTo == null) {
        return;
      }

      context.read<CortesCubit>().selectCorte(corteTo);
    },
    icon: const Icon(Icons.arrow_back_ios),
    color: transparent ? Colors.transparent : null,
  );
}
```

**Feedback visual:**
- Botón visible: Navegación disponible en esa dirección
- Botón invisible: No hay más cortes en esa dirección

### Especificaciones Técnicas

#### Gesture Arena y Resolución de Conflictos

Cuando múltiples GestureDetectors se superponen, Flutter usa un sistema de "arena":

```
User Touch
    ↓
┌───────────────────────┐
│   Gesture Arena       │
│                       │
│  Tap Detector    ───┐ │
│  Pan Detector    ───┤ │  → Winner
│  Scale Detector  ───┘ │
└───────────────────────┘
```

**Reglas de resolución:**
1. Todos los detectores reciben el primer pointer event
2. Los detectores declaran interés o se retiran
3. Detectores pueden bloquear a otros
4. El último detector en pie gana

#### Tipos de Callbacks en GestureDetector

```dart
GestureDetector(
  // Tap callbacks
  onTap: () {},
  onTapDown: (TapDownDetails details) {},
  onTapUp: (TapUpDetails details) {},
  onTapCancel: () {},

  // Double Tap
  onDoubleTap: () {},
  onDoubleTapDown: (TapDownDetails details) {},

  // Long Press
  onLongPress: () {},
  onLongPressStart: (LongPressStartDetails details) {},
  onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {},
  onLongPressEnd: (LongPressEndDetails details) {},

  // Pan (Drag)
  onPanStart: (DragStartDetails details) {},
  onPanUpdate: (DragUpdateDetails details) {},
  onPanEnd: (DragEndDetails details) {},

  // Scale (Pinch)
  onScaleStart: (ScaleStartDetails details) {},
  onScaleUpdate: (ScaleUpdateDetails details) {},
  onScaleEnd: (ScaleEndDetails details) {},

  child: MyWidget(),
)
```

#### InkWell vs GestureDetector

**InkWell**:
- Proporciona efectos de ripple Material
- Requiere Material widget ancestor
- Mejor para UX Material Design

**GestureDetector**:
- Sin efectos visuales automáticos
- Más ligero
- Mayor control sobre comportamiento

```dart
// InkWell con ripple effect
InkWell(
  onTap: () {},
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Tap me'),
  ),
)

// GestureDetector sin ripple
GestureDetector(
  onTap: () {},
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Tap me'),
  ),
)
```

#### Details Objects

Los callbacks reciben objetos `Details` con información contextual:

**TapDownDetails**:
```dart
onTapDown: (details) {
  print(details.globalPosition);  // Posición en coordenadas globales
  print(details.localPosition);   // Posición en coordenadas del widget
  print(details.kind);            // Tipo de pointer (touch, mouse, stylus)
}
```

**DragUpdateDetails**:
```dart
onPanUpdate: (details) {
  print(details.delta);           // Cambio desde último update
  print(details.globalPosition);  // Posición actual
  print(details.primaryDelta);    // Delta en eje principal
}
```

### Mejores Prácticas

1. **Usa InkWell para efectos Material**:
   ```dart
   InkWell(
     onTap: () {},
     borderRadius: BorderRadius.circular(8),
     child: Container(...),
   )
   ```

2. **Implementa feedback visual para todas las interacciones**:
   ```dart
   bool _isPressed = false;

   GestureDetector(
     onTapDown: (_) => setState(() => _isPressed = true),
     onTapUp: (_) => setState(() => _isPressed = false),
     onTapCancel: () => setState(() => _isPressed = false),
     child: Opacity(
       opacity: _isPressed ? 0.5 : 1.0,
       child: MyWidget(),
     ),
   )
   ```

3. **Usa hitTestBehavior apropiadamente**:
   ```dart
   GestureDetector(
     // opaque: Solo detecta toques en widgets no transparentes
     // translucent: Detecta toques pero permite que pasen a través
     // deferToChild: Detecta toques solo donde hay children
     behavior: HitTestBehavior.opaque,
     onTap: () {},
     child: Container(...),
   )
   ```

4. **Combina gestos con cuidado**:
   ```dart
   // Evitar conflictos entre onPan y onScale
   GestureDetector(
     onPanUpdate: (details) {
       // Solo se activará si no hay gesto de scale
     },
     child: MyWidget(),
   )
   ```

5. **Limpia controllers en dispose()**:
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

6. **Usa Listener para eventos de bajo nivel**:
   ```dart
   Listener(
     onPointerDown: (event) {},
     onPointerMove: (event) {},
     onPointerUp: (event) {},
     child: MyWidget(),
   )
   ```

### Desafíos Comunes

#### Problema: Gestos no se detectan

**Causa**: Widget hijo consume el toque o no hay área suficiente para tocar

**Solución**:
```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,  // Detecta en área completa
  onTap: () {},
  child: Container(
    width: 100,
    height: 100,
    child: Center(child: Text('Tap')),
  ),
)
```

#### Problema: Conflicto entre múltiples gestos

**Causa**: Pan y Scale no pueden coexistir en el mismo GestureDetector

**Solución**: Usar RawGestureDetector con control manual de la arena
```dart
RawGestureDetector(
  gestures: {
    AllowMultipleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
        AllowMultipleGestureRecognizer>(
      () => AllowMultipleGestureRecognizer(),
      (AllowMultipleGestureRecognizer instance) {
        instance.onTap = () {};
      },
    ),
  },
  child: MyWidget(),
)
```

#### Problema: Animaciones no se cancelan correctamente

**Causa**: No manejar onTapCancel

**Solución**: Siempre implementar onTapCancel
```dart
GestureDetector(
  onTapDown: (_) => _controller.forward(),
  onTapUp: (_) => _controller.reverse(),
  onTapCancel: () => _controller.reverse(),  // ✅ Importante
  child: MyWidget(),
)
```

## Referencias

### Documentación Interna
- [Custom Painting y SVG](/docs/features/02-custom-painting-and-svg.md) - Hit testing en CustomPaint
- [Widgets Reutilizables](/docs/components/01-reusable-widgets.md) - LoadingButton implementation
- [Visualización Interactiva del Cerebro](/docs/features/01-interactive-brain-visualization.md) - Uso práctico de GestureDetector

### Referencias Externas

1. **Flutter Gesture System**
   - https://docs.flutter.dev/ui/interactivity/gestures
   - Guía oficial de gestos

2. **GestureDetector API**
   - https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
   - Documentación completa de GestureDetector

3. **Gesture Arena**
   - https://api.flutter.dev/flutter/gestures/GestureArenaManager-class.html
   - Sistema de resolución de conflictos

4. **CustomPainter Hit Testing**
   - https://api.flutter.dev/flutter/rendering/CustomPainter/hitTest.html
   - Documentación de hit testing personalizado

### Bibliografía Académica

- Windmill, E. (2020). *Flutter in Action*. Manning Publications. (Capítulo 6: User Input and Gestures)
- Nielsen, J. (1994). *Usability Engineering*. Morgan Kaufmann. (Capítulo: Response Time)
- Norman, D. (2013). *The Design of Everyday Things*. Basic Books. (Capítulo: Feedback and Affordances)

## Lecturas Adicionales

**Siguiente**: [Widgets Reutilizables](/docs/components/01-reusable-widgets.md) - Construcción de componentes interactivos personalizados

**Relacionado**:
- [Layouts y Diseño Responsivo](/docs/ui-ux/02-layouts-and-responsive-design.md) - Stack para superposición de widgets interactivos
- [Painters](/docs/components/02-painters.md) - Implementación detallada de hit testing
