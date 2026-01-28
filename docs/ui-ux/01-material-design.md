# Material Design en Flutter

> **Nivel**: Principiante
> **Prerrequisitos**: Conocimientos básicos de Flutter y widgets
> **Tiempo de lectura**: 15 minutos

## Introducción

Imagina que quieres decorar tu casa. Podrías elegir muebles y colores al azar, pero probablemente el resultado no se vería profesional. En cambio, si sigues una guía de diseño de interiores con reglas sobre colores que combinan, espaciado entre muebles y tipos de iluminación, tu casa se verá coherente y agradable a la vista.

Material Design funciona de la misma manera para aplicaciones móviles. Es como un manual de estilo creado por Google que define cómo deben verse y comportarse los elementos de tu aplicación: qué tan grandes deben ser los botones, qué colores usar, cómo deben animarse las transiciones, y mucho más.

En esta aplicación de neuroanatomía, Material Design proporciona:

- **Colores consistentes**: Un esquema de color primario morado (`#6750A4`) que se usa en toda la aplicación
- **Componentes predefinidos**: Botones, barras de navegación, y otros elementos que ya se ven bien y funcionan correctamente
- **Espaciado uniforme**: Márgenes y paddings que siguen patrones consistentes
- **Animaciones suaves**: Transiciones entre pantallas que se sienten naturales

Cuando usas Material Design, tu aplicación automáticamente se ve profesional y familiar para los usuarios, porque muchas aplicaciones populares (Gmail, Google Maps, YouTube) siguen los mismos principios de diseño.

Flutter tiene soporte integrado para Material Design. Esto significa que no tienes que diseñar cada botón o ícono desde cero. En lugar de eso, usas widgets como `MaterialApp`, `Scaffold`, `AppBar`, y `FloatingActionButton` que ya implementan las reglas de Material Design por ti.

---

## Documentación Técnica Formal

### Fundamento Teórico

Material Design es un sistema de diseño desarrollado por Google en 2014, basado en principios de diseño físico y movimiento. El sistema utiliza metáforas de materiales táctiles (como papel y tinta) para crear una jerarquía visual coherente, un movimiento significativo y una experiencia de usuario predecible.

Los principios fundamentales de Material Design incluyen:

1. **Material como metáfora**: Las superficies y bordes de los materiales proporcionan pistas visuales basadas en la realidad
2. **Diseño audaz, gráfico e intencional**: Los elementos de diseño tipográfico, cuadrículas, espacio, escala, color e imágenes guían la atención del usuario
3. **Movimiento proporciona significado**: El movimiento respeta y refuerza al usuario como el principal iniciador

Flutter implementa Material Design 3 (también conocido como Material You) a través de su framework de widgets, proporcionando componentes pre-construidos que siguen las especificaciones de diseño de Google.

### Implementación en la Aplicación NeuroAnatomía

#### MaterialApp: Punto de Entrada

La aplicación utiliza `MaterialApp` como widget raíz, que proporciona funcionalidades esenciales de Material Design:

```dart
// /lib/main.dart, líneas 36-69
MaterialApp(
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
)
```

El `MaterialApp` proporciona:
- **Navigator**: Manejo de rutas y navegación
- **Theme**: Aplicación del tema personalizado a toda la aplicación
- **Localizations**: Soporte para internacionalización
- **MediaQuery**: Información sobre el dispositivo y orientación

#### Tema Personalizado

La aplicación define un tema personalizado en `/lib/theme.dart`:

```dart
// /lib/theme.dart, líneas 3-19
const _primaryColor = Color(0xFF6750A4);
const _secondaryColor = Color(0xFFFFF8F0);
const _tertiaryColor = Color(0xFFb58392);

ThemeData mainTheme() {
  final baseTheme = ThemeData.light(useMaterial3: true);
  final mainThemeTextTheme = baseTheme.textTheme;

  return baseTheme.copyWith(
    textTheme: mainThemeTextTheme,
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
    ),
  );
}
```

**Características del tema:**
- **Material 3**: Utiliza `useMaterial3: true` para habilitar los componentes más recientes
- **Color Scheme**: Define colores primary, secondary y tertiary siguiendo la especificación de Material Design
- **Theme Inheritance**: Usa `copyWith()` para extender el tema base sin sobrescribir todas las propiedades

#### Scaffold: Estructura de Página

Cada página de la aplicación usa `Scaffold`, que proporciona la estructura visual básica de Material Design:

```dart
// /lib/pages/home_page/home_page.dart, líneas 41-109
Scaffold(
  appBar: AppBar(
    title: const Image(
      image: AssetImage('assets/logo.png'),
      height: 40,
    ),
    actions: [
      IconButton(
        onPressed: () {
          context.read<AuthCubit>().logout();
        },
        icon: const Icon(Icons.logout),
      ),
    ],
    leading: PopupMenuButton<DiagramaType>(
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
    ),
  ),
  body: BlocConsumer<CortesCubit, CortesState>(
    // ... contenido del body
  ),
)
```

El `Scaffold` proporciona:
- **AppBar**: Barra superior con título, acciones y navegación
- **Body**: Área principal de contenido
- **FloatingActionButton**: Botón de acción flotante (usado en línea 124-145)

#### Componentes de Material Design Utilizados

1. **AppBar** (`home_page.dart:42-70`): Proporciona navegación y acciones contextuales
2. **IconButton** (`home_page.dart:48-53`): Botones de acción con íconos
3. **PopupMenuButton** (`home_page.dart:55-69`): Menú desplegable para selección de diagramas
4. **FloatingActionButton** (`home_page.dart:124-145`): Botón de acción prominente para toggle de vistas
5. **CircularProgressIndicator** (`main.dart:62`): Indicador de carga circular
6. **MaterialPageRoute** (`main.dart:49-52`): Transiciones de página con animaciones Material

#### InputDecoration Personalizado

Para mantener consistencia en los campos de entrada, la aplicación define un estilo reutilizable:

```dart
// /lib/theme.dart, líneas 21-29
final roundedTextInputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(64.0),
  ),
  filled: true,
  hintStyle: TextStyle(color: Colors.grey[800]),
  fillColor: Colors.white70,
  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
);
```

Este estilo aplica:
- Bordes redondeados (radio de 64.0 para apariencia de píldora)
- Fondo semi-transparente blanco
- Padding interno consistente

### Especificaciones Técnicas

#### Material 3 vs Material 2

Material 3 introduce mejoras significativas:

- **Dynamic Color**: Colores que se adaptan al sistema del usuario
- **Componentes actualizados**: Nuevos estilos para botones, chips, y navegación
- **Tokens de diseño**: Sistema de diseño basado en tokens para mayor consistencia
- **Elevación refinada**: Uso de capas de color en lugar de sombras para elevación

La aplicación habilita Material 3 explícitamente:

```dart
ThemeData.light(useMaterial3: true)
```

#### ColorScheme

Material Design 3 usa un sistema de roles de color:

| Rol | Uso en la App | Valor Hexadecimal |
|-----|---------------|-------------------|
| Primary | Elementos principales, FAB, AppBar highlights | `#6750A4` (morado) |
| Secondary | Fondos, superficies secundarias | `#FFF8F0` (beige claro) |
| Tertiary | Acentos, elementos terciarios | `#b58392` (rosa pálido) |

#### Elevation y Sombras

Material Design usa elevación para crear jerarquía visual. Flutter implementa esto mediante:

- **z-order**: Orden de apilamiento de widgets
- **BoxShadow**: Sombras proyectadas
- **Material widget**: Manejo automático de elevación

En Material 3, la elevación se expresa mediante overlays de color en lugar de sombras pronunciadas.

### Mejores Prácticas

1. **Usa useMaterial3**: Siempre habilita Material 3 para componentes modernos:
   ```dart
   ThemeData(useMaterial3: true)
   ```

2. **Define un ColorScheme consistente**: No uses colores arbitrarios, define un esquema:
   ```dart
   colorScheme: ColorScheme.light(
     primary: myPrimaryColor,
     secondary: mySecondaryColor,
   )
   ```

3. **Aprovecha Theme.of(context)**: Accede a los colores del tema dinámicamente:
   ```dart
   color: Theme.of(context).colorScheme.primary
   ```

4. **Usa widgets Material nativos**: Prefiere `ElevatedButton` sobre `Container` con decoración personalizada

5. **Respeta la guía de espaciado**: Usa múltiplos de 4 o 8 para padding y margins

6. **Implementa estados visuales**: Usa `MaterialStateProperty` para colores en diferentes estados (pressed, disabled, focused)

### Desafíos Comunes

#### Problema: Colores no se aplican correctamente

**Causa**: No envolver la aplicación en `MaterialApp` o no definir el tema

**Solución**:
```dart
MaterialApp(
  theme: mainTheme(),
  home: MyHomePage(),
)
```

#### Problema: Componentes se ven diferentes en Material 2 vs Material 3

**Causa**: Diferencias de diseño entre versiones

**Solución**: Ser explícito sobre qué versión usar y probar en ambas si es necesario

#### Problema: Elevación no visible en Material 3

**Causa**: Material 3 usa color tinting en lugar de sombras pronunciadas

**Solución**: Ajustar `surfaceTintColor` o usar `shadowColor` explícitamente si se necesitan sombras

## Referencias

### Documentación Interna
- [Widgets y UI](/docs/flutter-basics/02-widgets-and-ui.md) - Conceptos básicos de widgets
- [Layouts y Diseño Responsivo](/docs/ui-ux/02-layouts-and-responsive-design.md) - Cómo estructurar layouts
- [Componentes Interactivos](/docs/ui-ux/04-interactive-components.md) - Manejo de interacciones

### Referencias Externas

1. **Material Design Guidelines** (2024)
   - https://m3.material.io/
   - Especificación oficial de Material Design 3

2. **Flutter Material Library Documentation**
   - https://api.flutter.dev/flutter/material/material-library.html
   - API reference completa de widgets Material

3. **Google Material Design Blog**
   - https://material.io/blog
   - Actualizaciones y mejores prácticas

4. **Material Design Color System**
   - https://m3.material.io/styles/color/system/overview
   - Guía del sistema de colores

### Bibliografía Académica

- Duarte, M., & Baskinger, M. (2014). "Material Design". Google I/O 2014 Keynote.
- Nielsen, J. (1994). *Usability Engineering*. Morgan Kaufmann.
- Norman, D. (2013). *The Design of Everyday Things: Revised and Expanded Edition*. Basic Books.

## Lecturas Adicionales

**Siguiente**: [Layouts y Diseño Responsivo](/docs/ui-ux/02-layouts-and-responsive-design.md) - Aprende cómo estructurar layouts adaptativos

**Relacionado**:
- [Widgets Reutilizables](/docs/components/01-reusable-widgets.md) - Cómo crear componentes personalizados con Material Design
- [Navegación y Routing](/docs/ui-ux/03-navigation-and-routing.md) - Navegación entre pantallas Material
