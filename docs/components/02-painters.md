# Painters: Dibujo Personalizado con CustomPainter

> **Nivel**: Avanzado
> **Prerrequisitos**: CustomPaint, Canvas, Path, transformaciones de matrices
> **Tiempo de lectura**: 30 minutos

## Introducción

Imagina que tienes un lienzo en blanco y un set completo de pinceles, pinturas y herramientas de dibujo. Puedes dibujar cualquier cosa: líneas, círculos, formas irregulares, degradados, sombras. No estás limitado a formas predefinidas como rectángulos o círculos perfectos. Tienes control total sobre cada píxel.

`CustomPainter` en Flutter es exactamente eso: un lienzo en blanco donde puedes dibujar lo que quieras usando código. Es la API de bajo nivel de Flutter para gráficos 2D, dándote acceso directo al canvas de renderizado.

**Cuándo usar CustomPainter:**

- Formas complejas que no pueden crearse con widgets estándar
- Gráficos vectoriales (SVG paths)
- Visualizaciones de datos personalizadas
- Juegos y animaciones complejas
- Efectos visuales únicos

En esta aplicación de neuroanatomía, `CustomPainter` es esencial para:

1. **SegmentoPainter**: Dibuja y detecta toques en regiones irregulares del cerebro (basadas en paths SVG)
2. **VistaPainter**: Dibuja líneas punteadas de navegación entre cortes cerebrales

Estos painters permiten que formas orgánicas e irregulares (como el cerebro) sean interactivas y precisas, algo imposible con widgets estándar de Flutter.

---

## Documentación Técnica Formal

### Fundamento Teórico

`CustomPainter` es una clase abstracta que proporciona acceso al pipeline de renderizado de Flutter. Funciona en conjunto con `CustomPaint`, un widget que invoca el painter durante la fase de pintura del ciclo de renderizado.

**Conceptos fundamentales:**

1. **Canvas**: Superficie de dibujo que proporciona métodos de dibujo (drawPath, drawCircle, etc.)
2. **Paint**: Objeto que define cómo se dibuja (color, estilo, grosor de línea)
3. **Path**: Secuencia de comandos de dibujo vectorial (moveTo, lineTo, curveTo)
4. **Coordinate System**: Sistema de coordenadas donde (0,0) es la esquina superior izquierda

### Implementación en la Aplicación NeuroAnatomía

#### 1. SegmentoPainter: Regiones Clickeables del Cerebro

`SegmentoPainter` es el painter más complejo, responsable de dibujar regiones del cerebro:

```dart
// /lib/painters/segmento_painter.dart, líneas 1-59
import 'package:flutter/material.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';

class SegmentoPainter extends CustomPainter {
  final SegmentoCerebro segmento;
  final bool isHighlighted;
  final Size cerebroSize;
  final Color highlightColor;

  List<Path> scaledPaths = [];

  SegmentoPainter({
    required this.segmento,
    required this.isHighlighted,
    required this.cerebroSize,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final relation = size.width / cerebroSize.width;

    // canvas.drawPath(scaledPath, paint);
    for (var segmento in segmento.path) {
      scaledPaths.add(segmento.transform(Matrix4.diagonal3Values(
        relation,
        relation,
        1,
      ).storage)
        ..close());
    }

    final paint = Paint()
      ..color = isHighlighted ? highlightColor : Colors.transparent
      // ..color = highlightColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    for (var path in scaledPaths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    for (var path in scaledPaths) {
      if (path.contains(position)) {
        return true;
      }
    }
    return false;
  }
}
```

#### Método paint(): Renderizado del Segmento

El método `paint()` es llamado automáticamente por Flutter cuando el widget necesita renderizarse:

```dart
// /lib/painters/segmento_painter.dart, líneas 19-42
@override
void paint(Canvas canvas, Size size) {
  final relation = size.width / cerebroSize.width;

  for (var segmento in segmento.path) {
    scaledPaths.add(segmento.transform(Matrix4.diagonal3Values(
      relation,
      relation,
      1,
    ).storage)
      ..close());
  }

  final paint = Paint()
    ..color = isHighlighted ? highlightColor : Colors.transparent
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  for (var path in scaledPaths) {
    canvas.drawPath(path, paint);
  }
}
```

**Pasos del proceso:**

1. **Calcular relación de escala**: Compara el tamaño del widget con el tamaño original de la imagen
   ```dart
   final relation = size.width / cerebroSize.width;
   ```

2. **Transformar paths**: Escala cada path SVG al tamaño del widget
   ```dart
   segmento.transform(Matrix4.diagonal3Values(relation, relation, 1).storage)
   ```

3. **Cerrar paths**: Asegura que los paths formen regiones cerradas
   ```dart
   ..close()
   ```

4. **Configurar Paint**: Define cómo se dibuja (color, estilo de relleno)
   ```dart
   final paint = Paint()
     ..color = isHighlighted ? highlightColor : Colors.transparent
     ..style = PaintingStyle.fill
   ```

5. **Dibujar en canvas**: Renderiza cada path escalado
   ```dart
   canvas.drawPath(path, paint)
   ```

#### Matrix4: Transformaciones Geométricas

Las transformaciones de matriz permiten escalar, rotar y trasladar paths:

```dart
Matrix4.diagonal3Values(relation, relation, 1)
```

**Matriz diagonal 3D**:
```
[relation    0        0    0]
[0        relation    0    0]
[0           0        1    0]
[0           0        0    1]
```

**Efecto**:
- Escala X por `relation`
- Escala Y por `relation`
- Z permanece sin cambios (1)

**Transformaciones comunes**:
```dart
// Escala
Matrix4.diagonal3Values(scaleX, scaleY, 1)

// Traslación
Matrix4.translationValues(dx, dy, 0)

// Rotación (radianes)
Matrix4.rotationZ(angle)

// Combinación
Matrix4.identity()
  ..scale(2.0)
  ..translate(10.0, 20.0)
  ..rotateZ(0.5)
```

#### Hit Testing: Detectar Toques en Paths

El método `hitTest()` determina si un toque está dentro del path:

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

**Flujo de hit testing:**
1. Usuario toca la pantalla en posición `(x, y)`
2. Flutter llama `hitTest(Offset(x, y))` en cada CustomPainter
3. El painter verifica si el offset está dentro de sus paths
4. Si `hitTest()` retorna `true`, el `GestureDetector` recibe el evento tap

**Path.contains() internamente:**
- Usa algoritmo "ray casting" o "winding number"
- Dibuja un rayo desde el punto hacia el infinito
- Cuenta cuántas veces cruza el borde del path
- Número impar de cruces = punto dentro
- Número par de cruces = punto fuera

#### shouldRepaint(): Control de Optimización

```dart
// /lib/painters/segmento_painter.dart, líneas 44-47
@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
  return true;
}
```

**Nota**: Esta implementación siempre retorna `true`, causando repaint en cada rebuild.

**Optimización mejorada**:
```dart
@override
bool shouldRepaint(SegmentoPainter oldDelegate) {
  return oldDelegate.isHighlighted != isHighlighted ||
         oldDelegate.segmento != segmento;
}
```

Esto evitaría repaints innecesarios cuando solo cambia el estado de otros widgets.

#### 2. VistaPainter: Líneas de Navegación Punteadas

`VistaPainter` dibuja líneas punteadas para indicar navegación entre cortes:

```dart
// /lib/painters/vista_painter.dart, líneas 1-60
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class VistaPainter extends CustomPainter {
  final Path vista;
  final Size cerebroSize;

  Path scaledPath = Path();

  VistaPainter({
    required this.vista,
    required this.cerebroSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final relation = size.width / cerebroSize.width;
    scaledPath = vista;
    scaledPath = vista.transform(Matrix4.diagonal3Values(
      relation,
      relation,
      1,
    ).storage);

    final dashedPath = dashPath(
      scaledPath,
      dashArray: CircularIntervalList<double>(<double>[10.0, 10.0]),
    );

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    final pathBounds = scaledPath.getBounds();
    const padding = 10;
    final pathWithArea = Path()
      ..moveTo(pathBounds.left - padding, pathBounds.top - padding)
      ..lineTo(pathBounds.right + padding, pathBounds.top - padding)
      ..lineTo(pathBounds.right + padding, pathBounds.bottom + padding)
      ..lineTo(pathBounds.left - padding, pathBounds.bottom + padding)
      ..close();
    return pathWithArea.contains(position);
  }
}
```

#### Líneas Punteadas con path_drawing

El paquete `path_drawing` proporciona utilidades para crear efectos de línea:

```dart
// /lib/painters/vista_painter.dart, líneas 25-28
final dashedPath = dashPath(
  scaledPath,
  dashArray: CircularIntervalList<double>(<double>[10.0, 10.0]),
);
```

**Parámetros de dashArray:**
- Primer valor (`10.0`): Longitud del trazo visible
- Segundo valor (`10.0`): Longitud del espacio invisible
- Pattern se repite: `[10px dash, 10px gap, 10px dash, 10px gap, ...]`

**Patterns alternativos:**
```dart
// Guiones más largos
dashArray: CircularIntervalList<double>(<double>[20.0, 10.0])

// Pattern complejo
dashArray: CircularIntervalList<double>(<double>[10.0, 5.0, 2.0, 5.0])
// Resultado: [10px dash, 5px gap, 2px dot, 5px gap, repeat]
```

#### Paint Styles: Stroke vs Fill

```dart
// /lib/painters/vista_painter.dart, líneas 30-34
final paint = Paint()
  ..color = Colors.black
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke
  ..strokeWidth = 5;
```

**PaintingStyle opciones:**

| Estilo | Descripción | Uso |
|--------|-------------|-----|
| `PaintingStyle.fill` | Rellena el interior del path | Regiones sólidas, segmentos del cerebro |
| `PaintingStyle.stroke` | Dibuja solo el contorno | Líneas, bordes, indicadores de navegación |

**StrokeCap opciones:**

| Cap | Descripción | Visual |
|-----|-------------|--------|
| `StrokeCap.butt` | Bordes planos | `─────` |
| `StrokeCap.round` | Bordes redondeados | `─────` (con semicírculos en puntas) |
| `StrokeCap.square` | Bordes cuadrados que extienden más allá del punto final | `─────` (cuadrados en puntas) |

#### Hit Testing para Líneas

Las líneas son difíciles de tocar, así que `VistaPainter` crea un área rectangular alrededor:

```dart
// /lib/painters/vista_painter.dart, líneas 44-58
@override
bool hitTest(Offset position) {
  final pathBounds = scaledPath.getBounds();
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

**Proceso:**
1. Obtener límites (bounding box) del path original
2. Expandir el bounding box con padding de 10 píxeles en todas direcciones
3. Crear un path rectangular con los límites expandidos
4. Verificar si el toque está dentro del rectángulo expandido

**Visualización:**
```
Original line: ──────

Expanded hit area:
┌──────────┐
│──────────│  <- 10px padding arriba y abajo
└──────────┘
```

### Especificaciones Técnicas

#### Canvas API: Métodos de Dibujo

El objeto `Canvas` proporciona métodos para dibujar:

**Formas básicas:**
```dart
canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
canvas.drawCircle(Offset(cx, cy), radius, paint);
canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
canvas.drawOval(Rect.fromLTWH(x, y, width, height), paint);
canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
```

**Paths:**
```dart
canvas.drawPath(path, paint);
canvas.drawPoints(PointMode.points, [Offset(x1, y1), ...], paint);
```

**Texto:**
```dart
final textPainter = TextPainter(
  text: TextSpan(text: 'Hello'),
  textDirection: TextDirection.ltr,
);
textPainter.layout();
textPainter.paint(canvas, Offset(x, y));
```

**Imágenes:**
```dart
canvas.drawImage(image, Offset(x, y), paint);
canvas.drawImageRect(image, srcRect, dstRect, paint);
```

#### Paint Configuración Avanzada

El objeto `Paint` tiene muchas propiedades configurables:

```dart
final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true
  ..blendMode = BlendMode.srcOver
  ..colorFilter = ColorFilter.mode(Colors.red, BlendMode.modulate)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0)
  ..shader = LinearGradient(
      colors: [Colors.red, Colors.blue],
    ).createShader(Rect.fromLTWH(0, 0, 100, 100));
```

**Propiedades importantes:**

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `color` | `Color` | Color del dibujo |
| `strokeWidth` | `double` | Grosor de líneas |
| `style` | `PaintingStyle` | Fill vs Stroke |
| `strokeCap` | `StrokeCap` | Estilo de extremos de línea |
| `strokeJoin` | `StrokeJoin` | Estilo de uniones de líneas |
| `isAntiAlias` | `bool` | Suavizado de bordes |
| `blendMode` | `BlendMode` | Modo de mezcla con fondo |
| `shader` | `Shader` | Degradados o patterns |
| `maskFilter` | `MaskFilter` | Efectos de desenfoque |

#### Path API: Construcción de Formas

Los paths se construyen con comandos vectoriales:

```dart
final path = Path()
  ..moveTo(0, 0)                    // Mover sin dibujar
  ..lineTo(100, 0)                  // Línea recta
  ..lineTo(100, 100)
  ..close();                         // Cerrar path

// Curvas
path.quadraticBezierTo(cpx, cpy, x, y);      // Curva cuadrática
path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);  // Curva cúbica

// Formas predefinidas
path.addRect(Rect.fromLTWH(x, y, w, h));
path.addOval(Rect.fromLTWH(x, y, w, h));
path.addArc(rect, startAngle, sweepAngle);
path.addPolygon([Offset(x1,y1), Offset(x2,y2)], close);

// Operaciones de paths
final combined = Path.combine(PathOperation.union, path1, path2);
```

#### Coordinate Transformations

El canvas puede transformarse antes de dibujar:

```dart
@override
void paint(Canvas canvas, Size size) {
  // Guardar estado actual
  canvas.save();

  // Aplicar transformaciones
  canvas.translate(dx, dy);        // Mover origen
  canvas.rotate(angle);            // Rotar
  canvas.scale(sx, sy);            // Escalar
  canvas.skew(sx, sy);             // Sesgar

  // Dibujar con transformaciones aplicadas
  canvas.drawCircle(Offset.zero, 50, paint);

  // Restaurar estado
  canvas.restore();
}
```

**Canvas Stack:**
```
canvas.save()     → [State1]
canvas.save()     → [State1, State2]
canvas.restore()  → [State1]
canvas.restore()  → []
```

#### Performance: shouldRepaint Optimization

`shouldRepaint()` es crítico para performance:

```dart
@override
bool shouldRepaint(SegmentoPainter oldDelegate) {
  // Solo repaint si algo cambió
  return oldDelegate.isHighlighted != isHighlighted ||
         oldDelegate.segmento.id != segmento.id ||
         oldDelegate.cerebroSize != cerebroSize;
}
```

**Impacto de performance:**
- `return true`: Repaint en cada frame (costoso)
- `return false`: Nunca repaint (incorrecto si cambia data)
- Comparación selectiva: Repaint solo cuando necesario (óptimo)

### Mejores Prácticas

1. **Minimizar trabajo en paint()**:
   ```dart
   // Mal: Cálculos pesados en paint()
   @override
   void paint(Canvas canvas, Size size) {
     for (int i = 0; i < 1000; i++) {
       final path = computeComplexPath();  // ❌ Muy lento
       canvas.drawPath(path, paint);
     }
   }

   // Bien: Pre-calcular y cachear
   List<Path> _cachedPaths = [];

   void _computePaths() {
     _cachedPaths = List.generate(1000, (i) => computeComplexPath());
   }

   @override
   void paint(Canvas canvas, Size size) {
     for (final path in _cachedPaths) {  // ✅ Rápido
       canvas.drawPath(path, paint);
     }
   }
   ```

2. **Usar shouldRepaint correctamente**:
   ```dart
   @override
   bool shouldRepaint(MyPainter oldDelegate) {
     return oldDelegate.data != data;  // ✅ Específico
   }
   ```

3. **Implementar hitTest cuando necesario**:
   ```dart
   @override
   bool hitTest(Offset position) {
     return path.contains(position);
   }
   ```

4. **Usar save/restore para transformaciones**:
   ```dart
   canvas.save();
   canvas.rotate(angle);
   drawMyShape(canvas);
   canvas.restore();  // ✅ Restaura estado
   ```

5. **Reutilizar objetos Paint**:
   ```dart
   final _paint = Paint()..color = Colors.red;

   @override
   void paint(Canvas canvas, Size size) {
     canvas.drawCircle(Offset.zero, 10, _paint);  // ✅ Reutiliza
   }
   ```

6. **Usar antialiasing selectivamente**:
   ```dart
   // Para formas geométricas
   paint.isAntiAlias = true;

   // Para pixelart o performance crítica
   paint.isAntiAlias = false;
   ```

### Desafíos Comunes

#### Problema: Paths no se escalan correctamente

**Causa**: No aplicar transformaciones de tamaño

**Solución**: Calcular y aplicar relación de escala
```dart
final relation = size.width / originalWidth;
final scaledPath = path.transform(
  Matrix4.diagonal3Values(relation, relation, 1).storage
);
```

#### Problema: Hit testing no funciona

**Causa**: Olvidar implementar `hitTest()` o usar paths sin cerrar

**Solución**: Implementar hitTest y cerrar paths
```dart
@override
bool hitTest(Offset position) {
  return path.contains(position);
}

// Cerrar path
final path = Path()
  ..moveTo(0, 0)
  ..lineTo(100, 0)
  ..lineTo(100, 100)
  ..close();  // ✅ Importante para contains()
```

#### Problema: Performance pobre con muchos paths

**Causa**: Repaint innecesario o cálculos pesados en paint()

**Solución**: Optimizar shouldRepaint y pre-calcular
```dart
// Cache paths
List<Path> _cachedPaths = [];

void updatePaths(List<Data> data) {
  _cachedPaths = data.map((d) => d.toPath()).toList();
  notifyListeners();
}

@override
bool shouldRepaint(MyPainter old) {
  return old._cachedPaths != _cachedPaths;
}
```

#### Problema: Transformaciones acumulativas incorrectas

**Causa**: No usar save/restore

**Solución**: Siempre usar save/restore
```dart
canvas.save();
canvas.rotate(angle);
drawShape1(canvas);
canvas.restore();  // ✅ Restaura antes de siguiente shape

canvas.save();
canvas.scale(2.0);
drawShape2(canvas);
canvas.restore();
```

## Referencias

### Documentación Interna
- [Custom Painting y SVG](/docs/features/02-custom-painting-and-svg.md) - Uso en la app
- [Componentes Interactivos](/docs/ui-ux/04-interactive-components.md) - Integración con GestureDetector
- [Visualización Interactiva del Cerebro](/docs/features/01-interactive-brain-visualization.md) - Uso práctico

### Referencias Externas

1. **CustomPainter API**
   - https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
   - Documentación oficial

2. **Canvas API**
   - https://api.flutter.dev/flutter/dart-ui/Canvas-class.html
   - Referencia completa de métodos de dibujo

3. **Path API**
   - https://api.flutter.dev/flutter/dart-ui/Path-class.html
   - Construcción de formas vectoriales

4. **path_drawing Package**
   - https://pub.dev/packages/path_drawing
   - Utilidades para efectos de path (dashed lines, etc.)

5. **SVG Path Specification**
   - https://www.w3.org/TR/SVG/paths.html
   - Especificación W3C de paths SVG

### Bibliografía Académica

- Eisenberg, J. D., & Bellamy-Royds, A. (2014). *SVG Essentials* (2nd ed.). O'Reilly Media.
- Foley, J. D., et al. (1995). *Computer Graphics: Principles and Practice* (2nd ed.). Addison-Wesley. (Capítulo: 2D Graphics)
- W3C (2018). *Scalable Vector Graphics (SVG) 2 Specification*. https://www.w3.org/TR/SVG2/

## Lecturas Adicionales

**Relacionado**:
- [Custom Painting y SVG](/docs/features/02-custom-painting-and-svg.md) - Implementación completa en la app
- [Widgets Reutilizables](/docs/components/01-reusable-widgets.md) - InteractiveIlustracion que usa painters
- [Programación Asíncrona](/docs/technical/01-async-programming.md) - Carga asíncrona de imágenes para painters
