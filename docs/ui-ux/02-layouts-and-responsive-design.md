# Layouts y Diseño Responsivo en Flutter

> **Nivel**: Intermedio
> **Prerrequisitos**: Widgets básicos, Material Design
> **Tiempo de lectura**: 20 minutos

## Introducción

Imagina que estás construyendo una casa con bloques de LEGO. No puedes simplemente apilar los bloques al azar y esperar que la casa se vea bien. Necesitas un plan: algunos bloques van uno al lado del otro (en fila), otros van uno encima del otro (en columna), y algunos necesitan estar uno sobre otro en la misma posición (apilados).

Los layouts en Flutter funcionan exactamente así. Tienes widgets especiales que actúan como "contenedores organizadores" que deciden cómo se posicionan otros widgets:

- **Row**: Coloca widgets en una fila horizontal (como libros en un estante)
- **Column**: Coloca widgets en una columna vertical (como pisos en un edificio)
- **Stack**: Apila widgets uno sobre otro (como cartas en un mazo)

Pero hay un desafío adicional: tu aplicación podría ejecutarse en un teléfono pequeño, una tablet grande, o incluso en una computadora de escritorio. El diseño responsivo significa que tu app se adapta automáticamente al tamaño de la pantalla, como una página web que se ve bien tanto en móvil como en computadora.

En esta aplicación de neuroanatomía, el diseño responsivo es crucial. Por ejemplo, la ilustración interactiva del cerebro debe verse bien tanto en un iPhone pequeño como en un iPad grande. El código calcula dinámicamente el tamaño apropiado basándose en el ancho de la pantalla disponible:

```dart
final width = MediaQuery.of(context).size.width;
final viewWidth = width > 840 ? width * 0.40 : width * 0.8;
```

Esto significa: "Si la pantalla es ancha (más de 840 píxeles), usa el 40% del ancho. Si no, usa el 80%". Así, la ilustración siempre se ve proporcionada sin importar el dispositivo.

---

## Documentación Técnica Formal

### Fundamento Teórico

El sistema de layout de Flutter se basa en el algoritmo de restricciones (constraints), que fluye en la siguiente dirección:

1. **Constraints go down**: Los widgets padres pasan restricciones (min/max width/height) a sus hijos
2. **Sizes go up**: Los widgets hijos deciden su tamaño dentro de esas restricciones y lo reportan al padre
3. **Parent sets position**: El padre posiciona a los hijos basándose en sus tamaños

Este modelo, conocido como "box constraints model", es fundamental para entender cómo Flutter renderiza interfaces.

### Implementación en la Aplicación NeuroAnatomía

#### Widgets de Layout Fundamentales

##### 1. Column: Layouts Verticales

La `HomePage` usa `Column` para organizar los botones de navegación verticalmente:

```dart
// /lib/pages/home_page/home_page.dart, líneas 424-443
Widget _buildNavigationButtons(
    CortesReady cortesState, BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Expanded(child: _buildAtrasButton(context)),
          Expanded(child: _buildArribaButton(context)),
          const Spacer(),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIzquierdaButton(context),
          _buildDerechaButton(context),
        ],
      ),
      _buildAbajoButton(context),
    ],
  );
}
```

**Propiedades clave de Column:**
- `mainAxisAlignment`: Controla el espaciado vertical (eje principal)
- `crossAxisAlignment`: Controla la alineación horizontal (eje transversal)
- `mainAxisSize`: Define si la columna debe ocupar todo el espacio o solo el necesario

##### 2. Row: Layouts Horizontales

Dentro de la `Column` anterior, se usan `Row` widgets para botones horizontales:

```dart
// /lib/pages/home_page/home_page.dart, líneas 427-433
Row(
  children: [
    Expanded(child: _buildAtrasButton(context)),
    Expanded(child: _buildArribaButton(context)),
    const Spacer(),
  ],
)
```

El widget `Expanded` es crucial aquí: indica que ese hijo debe expandirse para llenar el espacio disponible.

**Diferencias entre Expanded y Flexible:**
- `Expanded`: Fuerza al hijo a llenar el espacio disponible (`flex: 1` por defecto)
- `Flexible`: Permite al hijo decidir su tamaño, pero puede expandirse si hay espacio
- `Spacer`: Es un `Expanded` con un `SizedBox` vacío (útil para espacios en blanco)

##### 3. Stack: Superposición de Widgets

La ilustración interactiva usa `Stack` para superponer la imagen del cerebro con las regiones clickeables:

```dart
// /lib/widgets/interactive_ilustracion.dart, líneas 60-133
Stack(
  children: [
    Image.memory(
      currentImage.bytes,
      fit: BoxFit.cover,
      gaplessPlayback: false,
      filterQuality: FilterQuality.high,
    ),
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
    }),
    if (showVistas)
      ...corteCerebro.vistas.map((vista) {
        // ... código de vistas
      }),
    if (showSwitchImageMode && readyState.images.length > 1)
      Positioned(
        top: 0,
        right: 0,
        child: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () {
            onImageModeChange?.call(
              imageMode == ImageMode.real
                  ? ImageMode.aquarela
                  : ImageMode.real,
            );
          },
        ),
      ),
  ],
)
```

**Características del Stack:**
- Los hijos se apilan en orden (el último dibujado está arriba)
- `Positioned` permite posicionamiento absoluto dentro del Stack
- Spread operator (`...`) para agregar listas de widgets dinámicamente

#### Diseño Responsivo con LayoutBuilder

`LayoutBuilder` permite acceder a las restricciones del widget padre y ajustar el layout dinámicamente:

```dart
// /lib/widgets/interactive_ilustracion.dart, líneas 50-134
LayoutBuilder(builder: (context, constraints) {
  final width = constraints.maxWidth;
  final currentImage = readyState.imageForMode(imageMode);

  if (currentImage == null) {
    return const Center(
      child: Text('No se pudo cargar la imagen'),
    );
  }

  return Stack(
    children: [
      Image.memory(
        currentImage.bytes,
        fit: BoxFit.cover,
        gaplessPlayback: false,
        filterQuality: FilterQuality.high,
      ),
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
                // ... parámetros del painter
              ),
            ),
            onTap: () {
              onEstructuraTap?.call(segmento);
            });
      }),
      // ... más hijos
    ],
  );
})
```

**Ventajas de LayoutBuilder:**
- Acceso directo a `constraints.maxWidth` y `constraints.maxHeight`
- Permite diferentes layouts según el espacio disponible
- Se reconstruye automáticamente cuando las constraints cambian

#### MediaQuery: Información del Dispositivo

`MediaQuery` proporciona información sobre el dispositivo y la pantalla:

```dart
// /lib/pages/home_page/home_page.dart, líneas 389-420
Widget _buildInteractiveIlustration(
    CortesReady cortesState, BuildContext context) {
  final width = context.mediaQuery.size.width;

  final viewWidth = width > 840 ? width * 0.40 : width * 0.8;
  return Center(
    child: SizedBox(
      width: viewWidth,
      child: InteractiveIlustracion(
        key: ValueKey(cortesState.selectedCorte.id),
        corteCerebro: cortesState.selectedCorte,
        // ... más parámetros
      ),
    ),
  );
}
```

**Información disponible en MediaQuery:**
- `size`: Tamaño lógico de la pantalla
- `devicePixelRatio`: Ratio de píxeles físicos a píxeles lógicos
- `padding`: Áreas del sistema (notch, barra de estado)
- `viewInsets`: Áreas ocupadas por teclado u otros overlays
- `orientation`: Portrait vs Landscape

#### Cálculo de Altura Dinámica del Panel

El panel deslizante calcula su altura máxima basándose en el tamaño de la pantalla:

```dart
// /lib/pages/home_page/home_page.dart, líneas 148-196
Widget _buildBody(BuildContext context, CortesReady cortesState) {
  final size = context.mediaQuery.size;
  final panelHeightOpen =
      (size.height * 0.5) - context.mediaQuery.padding.top;

  return SlidingUpPanel(
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
    // ... más configuración
  );
}
```

**Cálculos responsivos:**
- Panel ocupa 50% de la altura de la pantalla menos el padding superior
- Body tiene padding inferior del 20% de la altura
- Márgenes y padding proporcionales al tamaño de pantalla

#### BoxFit: Ajuste de Imágenes

Para mantener proporciones correctas de las imágenes del cerebro:

```dart
// /lib/widgets/interactive_ilustracion.dart, líneas 62-67
Image.memory(
  currentImage.bytes,
  fit: BoxFit.cover,
  gaplessPlayback: false,
  filterQuality: FilterQuality.high,
)
```

**Opciones de BoxFit:**
- `BoxFit.cover`: Cubre todo el espacio, puede recortar la imagen
- `BoxFit.contain`: Contiene la imagen completa, puede dejar espacios en blanco
- `BoxFit.fill`: Estira la imagen para llenar el espacio (puede distorsionar)
- `BoxFit.fitWidth`: Ajusta al ancho
- `BoxFit.fitHeight`: Ajusta a la altura

### Especificaciones Técnicas

#### Sistema de Constraints

Flutter usa un sistema de "tight" y "loose" constraints:

**Tight constraints** (restricciones ajustadas):
```dart
BoxConstraints.tight(Size(100, 100))
// minWidth = maxWidth = 100
// minHeight = maxHeight = 100
```

**Loose constraints** (restricciones flexibles):
```dart
BoxConstraints.loose(Size(100, 100))
// minWidth = minHeight = 0
// maxWidth = maxWidth = 100
```

#### Flexibilidad con Flex

`Row` y `Column` extienden de `Flex`, que maneja la distribución de espacio:

```dart
Row(
  children: [
    Expanded(flex: 2, child: Widget1()),  // Recibe 2/3 del espacio
    Expanded(flex: 1, child: Widget2()),  // Recibe 1/3 del espacio
  ],
)
```

El algoritmo calcula:
1. Espacio total disponible
2. Espacio consumido por hijos no-flex
3. Espacio restante dividido según valores de `flex`

#### Alignment y Positioning

**MainAxisAlignment** (eje principal):
- `start`: Inicio del eje
- `end`: Final del eje
- `center`: Centro del eje
- `spaceBetween`: Espacio entre hijos
- `spaceAround`: Espacio alrededor de hijos
- `spaceEvenly`: Espacio uniforme

**CrossAxisAlignment** (eje transversal):
- `start`: Inicio del eje transversal
- `end`: Final del eje transversal
- `center`: Centro del eje transversal
- `stretch`: Estirar para llenar
- `baseline`: Alinear por baseline de texto

### Mejores Prácticas

1. **Usa LayoutBuilder para layouts complejos responsivos**:
   ```dart
   LayoutBuilder(builder: (context, constraints) {
     if (constraints.maxWidth > 600) {
       return WideLayout();
     } else {
       return NarrowLayout();
     }
   })
   ```

2. **Evita hardcodear tamaños**:
   ```dart
   // Mal
   Container(width: 300, height: 200, ...)

   // Bien
   Container(
     width: MediaQuery.of(context).size.width * 0.8,
     ...
   )
   ```

3. **Usa Expanded/Flexible apropiadamente**:
   ```dart
   Row(
     children: [
       Expanded(child: Text('Este texto puede ser largo...')),
       Icon(Icons.arrow_forward),
     ],
   )
   ```

4. **Considera orientation changes**:
   ```dart
   MediaQuery.of(context).orientation == Orientation.portrait
     ? PortraitLayout()
     : LandscapeLayout()
   ```

5. **Usa AspectRatio para mantener proporciones**:
   ```dart
   AspectRatio(
     aspectRatio: 16 / 9,
     child: Image.network(url),
   )
   ```

6. **Implementa breakpoints para diferentes tamaños de pantalla**:
   ```dart
   static const mobileBreakpoint = 600;
   static const tabletBreakpoint = 840;
   static const desktopBreakpoint = 1200;
   ```

### Desafíos Comunes

#### Problema: "RenderFlex overflowed" error

**Causa**: Un Row o Column tiene más contenido del que puede mostrar

**Soluciones**:
```dart
// Opción 1: Usar Expanded
Row(
  children: [
    Expanded(child: Text('Texto largo...')),
  ],
)

// Opción 2: Usar SingleChildScrollView
SingleChildScrollView(
  child: Column(
    children: [...muchos widgets...],
  ),
)

// Opción 3: Usar Flexible con overflow
Flexible(
  child: Text(
    'Texto largo...',
    overflow: TextOverflow.ellipsis,
  ),
)
```

#### Problema: Widget no respeta constraints

**Causa**: Algunos widgets ignoran constraints del padre (ej: ListView sin altura limitada)

**Solución**:
```dart
// Envolver en SizedBox o Expanded
SizedBox(
  height: 200,
  child: ListView(...),
)
```

#### Problema: Stack children no posicionados correctamente

**Causa**: Sin Positioned, los hijos se alinean en top-left por defecto

**Solución**:
```dart
Stack(
  children: [
    BackgroundWidget(),
    Positioned(
      top: 10,
      right: 10,
      child: IconButton(...),
    ),
  ],
)
```

#### Problema: MediaQuery retorna valores incorrectos

**Causa**: Llamar MediaQuery antes de que MaterialApp se construya

**Solución**: Asegurar que MediaQuery se llama dentro del árbol de MaterialApp

## Referencias

### Documentación Interna
- [Material Design](/docs/ui-ux/01-material-design.md) - Fundamentos de diseño
- [Widgets y UI](/docs/flutter-basics/02-widgets-and-ui.md) - Conceptos básicos de widgets
- [Componentes Interactivos](/docs/ui-ux/04-interactive-components.md) - Interacciones con layouts

### Referencias Externas

1. **Flutter Layout Documentation**
   - https://docs.flutter.dev/ui/layout
   - Guía oficial de layouts

2. **Understanding Constraints**
   - https://docs.flutter.dev/ui/layout/constraints
   - Explicación detallada del modelo de constraints

3. **Responsive Design in Flutter**
   - https://docs.flutter.dev/ui/layout/responsive-adaptive
   - Patrones de diseño responsivo

4. **Flutter Widget Catalog - Layout**
   - https://docs.flutter.dev/ui/widgets/layout
   - Catálogo completo de widgets de layout

### Bibliografía Académica

- Windmill, E. (2020). *Flutter in Action*. Manning Publications. (Capítulo 5: Layouts)
- Moroney, L., & Windmill, E. (2019). *Beginning Flutter*. Wiley. (Capítulo 4: Building Layouts)
- Soares, P. (2021). *Flutter Complete Reference*. Alberto Miola. (Sección: Layout System)

## Lecturas Adicionales

**Siguiente**: [Navegación y Routing](/docs/ui-ux/03-navigation-and-routing.md) - Cómo navegar entre pantallas

**Relacionado**:
- [Custom Painting y SVG](/docs/features/02-custom-painting-and-svg.md) - Cálculos de tamaño para CustomPaint
- [Visualización Interactiva del Cerebro](/docs/features/01-interactive-brain-visualization.md) - Uso práctico de layouts responsivos
