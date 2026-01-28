# Estructura de Carpetas del Proyecto

> **Nivel**: Principiante-Intermedio
> **Prerrequisitos**: 01-app-architecture-overview.md
> **Tiempo de lectura**: 15 minutos

## Introducción

### Organización: La Biblioteca del Código

Imagina una biblioteca gigante sin sistema de organización: los libros de cocina mezclados con novelas de terror, los diccionarios junto a cómics, todo en caos. Encontrar algo sería imposible. Ahora imagina la misma biblioteca perfectamente organizada: ficción en un ala, no-ficción en otra, cada sección con subsecciones, cada estante etiquetado. Puedes encontrar cualquier libro en minutos.

El código es igual. Una aplicación puede tener cientos de archivos. Sin organización clara, encontrar dónde vive cierta funcionalidad se vuelve una pesadilla. La estructura de carpetas es el sistema de catalogación de tu biblioteca de código.

### El Directorio `/lib`: El Corazón del Código

En Flutter, todo el código fuente de la aplicación vive en la carpeta `/lib` (de "library"). Esta carpeta contiene la esencia de tu aplicación. Veamos cómo está organizada:

```
lib/
├── cubits/              ← 🧠 Cerebros (lógica de negocio)
├── models/              ← 📦 Cajas de datos
├── pages/               ← 📱 Pantallas de la app
├── services/            ← 🔧 Trabajadores (acceso a datos)
├── repositories/        ← 📚 Bibliotecas de datos
├── widgets/             ← 🧩 Piezas reutilizables
├── painters/            ← 🎨 Artistas (dibujo personalizado)
├── json_converters/     ← 🔄 Traductores de datos
├── extensions/          ← ⚡ Súper poderes extras
├── env/                 ← 🔐 Configuración secreta
├── main.dart            ← 🚀 Punto de arranque
├── theme.dart           ← 🎨 Estilos visuales
└── firebase_options.dart ← 🔥 Configuración de Firebase
```

Cada carpeta tiene un propósito claro. Veámoslas en detalle.

### `/cubits` - Los Cerebros de la Operación

**Qué contiene**: Toda la lógica de negocio de la aplicación usando el patrón Cubit.

**Organización**:
```
cubits/
├── auth_cubit/
│   ├── auth_cubit.dart       ← El cerebro de autenticación
│   └── auth_state.dart       ← Estados posibles de auth
├── cortes_cubit/
│   ├── cortes_cubit.dart     ← Gestión de cortes cerebrales
│   └── cortes_state.dart     ← Estados de carga/error/éxito
├── quiz_cubit/
│   ├── quiz_cubit.dart       ← Generación de quizzes
│   └── quiz_state.dart       ← Estados del quiz
├── diagramas_cubit/
│   ├── diagramas_cubit.dart  ← Gestión de diagramas
│   └── diagramas_state.dart  ← Estados de diagramas
└── corte_interactivo/
    ├── corte_interactivo_cubit.dart  ← Interacción con cortes
    └── corte_interactivo_state.dart  ← Estados de interacción
```

**Convención**: Cada Cubit tiene su propia carpeta con dos archivos: el Cubit mismo y sus estados. Esto mantiene relacionado el código que va junto.

**Analogía**: Piensa en cada Cubit como un gerente de departamento. El gerente de recursos humanos (AuthCubit) maneja empleados (usuarios), el gerente de inventario (CortesCubit) maneja productos (cortes cerebrales).

### `/models` - Las Cajas de Datos

**Qué contiene**: Clases que representan datos, como objetos del mundo real.

**Archivos clave**:
```
models/
├── corte_cerebro.dart        ← Representa un corte cerebral
├── corte_cerebro.g.dart      ← Código generado para JSON
├── segmento_cerebro.dart     ← Parte de un corte (región anatómica)
├── segmento_cerebro.g.dart   ← Código generado
├── diagrama.dart             ← Representa un diagrama anatómico
├── diagrama.g.dart           ← Código generado
├── note.dart                 ← Nota del usuario
├── note.g.dart               ← Código generado
├── quiz.dart                 ← Un quiz completo
├── quiz.g.dart               ← Código generado
├── quiz_question.dart        ← Una pregunta de quiz
├── quiz_answer.dart          ← Una respuesta de quiz
├── vista_cerebro.dart        ← Vista de navegación del cerebro
└── activity.dart             ← Actividad/log del usuario
```

**Archivos `.g.dart`**: El sufijo `.g` significa "generated" (generado). Estos archivos los crea automáticamente la herramienta `json_serializable` y contienen código boilerplate para convertir objetos de Dart a JSON y viceversa. Nunca debes editarlos manualmente.

**Analogía**: Los modelos son como formularios o plantillas. Un formulario de "empleado" tiene campos como nombre, edad, puesto. El modelo `CorteCerebro` tiene campos como título, imagen, segmentos.

### `/pages` - Las Pantallas de la Aplicación

**Qué contiene**: Cada pantalla completa de la aplicación.

**Organización**:
```
pages/
├── auth_page/
│   ├── auth_page.dart        ← Pantalla de login/registro
│   └── widgets/
│       └── auth_form.dart    ← Formulario de auth (widget específico)
├── home_page/
│   └── home_page.dart        ← Pantalla principal (visualización de cerebro)
├── diagramas_page/
│   └── diagramas_page.dart   ← Galería de diagramas
├── notes_page/
│   └── notes_page.dart       ← Lista de notas del usuario
├── note_form_page/
│   └── note_form_page.dart   ← Crear/editar nota
└── quiz_page/
    └── quiz_page.dart        ← Pantalla de quiz interactivo
```

**Convención**: Cada página tiene su propia carpeta. Si tiene widgets que solo usa esa página, van en una subcarpeta `widgets/` dentro de la carpeta de la página.

**Analogía**: Piensa en las pages como habitaciones en una casa. La cocina (HomePage) es diferente al baño (AuthPage). Cada una tiene su propósito y elementos específicos.

### `/services` - Los Trabajadores

**Qué contiene**: Clases que realizan trabajo real: hablar con Firebase, llamar APIs, procesar datos.

**Archivos**:
```
services/
├── cortes_service.dart       ← Obtiene cortes desde Firebase
├── diagramas_service.dart    ← Obtiene diagramas desde Firebase
├── notes_service.dart        ← CRUD de notas en Firestore
├── chat_gpt_service.dart     ← Integración con OpenAI API
├── activities_service.dart   ← Registra actividades del usuario
└── user_service.dart         ← Gestiona datos de usuario
```

**Diferencia con Repositories**: Los Services contienen la lógica específica de negocio y acceso a datos. Los Repositories son abstracciones más generales. En esta app, hay solo un Repository (AuthRepository) pero múltiples Services.

**Analogía**: Si los Cubits son gerentes, los Services son los trabajadores que ejecutan tareas: uno va al almacén (Firebase), otro llama a proveedores (OpenAI API), otro organiza el inventario.

### `/repositories` - Abstracciones de Datos

**Qué contiene**: Wrappers alrededor de fuentes de datos externas.

**Archivos**:
```
repositories/
└── auth_repository.dart      ← Abstrae Firebase Authentication
```

**Por qué tan pocos**: Esta app tiene arquitectura pragmática. Para autenticación, tiene sentido tener un Repository (podría cambiar de Firebase a otra solución). Para otras operaciones, los Services son suficientes.

**Analogía**: Un Repository es como un intermediario o agente. No importa si el proveedor es Firebase, AWS, o un servidor propio - el Repository presenta la misma interfaz.

### `/widgets` - Piezas Reutilizables

**Qué contiene**: Widgets personalizados que se usan en múltiples lugares.

**Archivos**:
```
widgets/
├── loading_button.dart       ← Botón con indicador de carga
├── interactive_ilustracion.dart  ← Widget para cortes interactivos
└── drag_indicator.dart       ← Indicador visual de arrastre
```

**Diferencia con widgets en pages/**: Los widgets aquí son reutilizables en múltiples pantallas. Los widgets dentro de `pages/auth_page/widgets/` solo se usan en AuthPage.

**Analogía**: Estos son como herramientas en un cinturón de herramientas: los usas en diferentes proyectos y contextos.

### `/painters` - Artistas del Canvas

**Qué contiene**: Clases CustomPainter que dibujan gráficos personalizados.

**Archivos**:
```
painters/
├── segmento_painter.dart     ← Dibuja segmentos anatómicos del cerebro
└── vista_painter.dart        ← Dibuja indicadores de navegación (flechas)
```

**Qué hacen**: Flutter permite dibujar píxeles arbitrarios en un lienzo usando la clase `CustomPainter`. Aquí se dibuja las regiones anatómicas del cerebro con paths SVG.

**Analogía**: Son como artistas con pinceles. Les das un lienzo (Canvas) y ellos pintan exactamente lo que necesitas: en este caso, segmentos anatómicos del cerebro.

### `/json_converters` - Traductores de Datos

**Qué contiene**: Conversores personalizados para serialización JSON.

**Archivos**:
```
json_converters/
├── path_converter.dart       ← Convierte strings SVG a objetos Path
└── path_list_converter.dart  ← Convierte listas de paths SVG
```

**Por qué existen**: Algunos tipos de datos de Dart (como `Path` de Flutter) no tienen conversión JSON automática. Estos conversores enseñan a `json_serializable` cómo convertirlos.

**Analogía**: Son como traductores especializados. La mayoría de idiomas tienen traducciones directas, pero algunos conceptos necesitan un traductor experto que entienda contexto cultural.

### `/extensions` - Súper Poderes Extras

**Qué contiene**: Extension methods que agregan funcionalidad a clases existentes.

**Archivos**:
```
extensions/
└── context_extension.dart    ← Atajos para BuildContext
```

**Qué hace**: Agrega métodos convenientes a `BuildContext`, como `context.theme` en lugar de `Theme.of(context)`.

**Analogía**: Es como agregar accesorios a tu teléfono. El teléfono funciona sin ellos, pero un PopSocket o un case con soporte lo hacen más cómodo de usar.

### `/env` - Configuración Secreta

**Qué contiene**: Variables de entorno y configuración.

**Archivos**:
```
env/
└── env.dart    ← Clase generada con API keys y configuración
```

**Seguridad**: El archivo `.env` con las claves reales NO está en el repositorio (está en `.gitignore`). Esta clase generada lee esas variables de manera segura.

### Archivos en la Raíz de `/lib`

**`main.dart`**: El punto de entrada de la aplicación. Es el primer archivo que se ejecuta cuando inicias la app.

**`theme.dart`**: Define colores, estilos de texto, y otros aspectos visuales globales.

**`firebase_options.dart`**: Configuración automáticamente generada para conectar con Firebase. Contiene IDs de proyecto, API keys públicas, etc.

---

## Documentación Técnica Formal

### Fundamento Teórico

#### Organización Modular del Código

La organización del código fuente en estructuras de directorios coherentes es fundamental para la mantenibilidad y escalabilidad de proyectos de software (Martin, 2008). Una estructura de carpetas bien diseñada debe:

1. **Reflejar la arquitectura del sistema**: La organización física debe mapear a la arquitectura lógica
2. **Facilitar la navegación**: Los desarrolladores deben poder localizar código intuitivamente
3. **Agrupar código relacionado**: Alta cohesión dentro de módulos, bajo acoplamiento entre módulos
4. **Escalar con el proyecto**: La estructura debe soportar crecimiento sin reorganización masiva

#### Principios de Organización

**Organización por Capa (Layer-based Organization)**

El proyecto separa código por capa arquitectónica:
- `pages/`, `widgets/`, `painters/` → Capa de Presentación
- `cubits/` → Capa de Lógica de Negocio
- `services/`, `repositories/`, `models/` → Capa de Datos

**Organización por Feature (Feature-based Organization)**

Dentro de carpetas como `cubits/` y `pages/`, la organización es por feature (característica):
- `auth_cubit/` contiene todo lo relacionado con autenticación
- `quiz_cubit/` contiene todo lo relacionado con quizzes

**Ventaja híbrida**: Combina organización por capa (alto nivel) con organización por feature (dentro de capas), obteniendo beneficios de ambos enfoques.

### Implementación en la Aplicación NeuroAnatomía

#### Estructura Completa del Directorio `/lib`

```
lib/
├── cubits/                          # Business Logic Layer
│   ├── auth_cubit/
│   │   ├── auth_cubit.dart
│   │   └── auth_state.dart
│   ├── cortes_cubit/
│   │   ├── cortes_cubit.dart
│   │   └── cortes_state.dart
│   ├── diagramas_cubit/
│   │   ├── diagramas_cubit.dart
│   │   └── diagramas_state.dart
│   ├── quiz_cubit/
│   │   ├── quiz_cubit.dart
│   │   └── quiz_state.dart
│   └── corte_interactivo/
│       ├── corte_interactivo_cubit.dart
│       └── corte_interactivo_state.dart
│
├── models/                          # Data Layer - Domain Models
│   ├── corte_cerebro.dart
│   ├── corte_cerebro.g.dart
│   ├── segmento_cerebro.dart
│   ├── segmento_cerebro.g.dart
│   ├── vista_cerebro.dart
│   ├── vista_cerebro.g.dart
│   ├── ilustracion_cerebro.dart
│   ├── diagrama.dart
│   ├── diagrama.g.dart
│   ├── note.dart
│   ├── note.g.dart
│   ├── quiz.dart
│   ├── quiz.g.dart
│   ├── quiz_question.dart
│   ├── quiz_question.g.dart
│   ├── quiz_answer.dart
│   ├── activity.dart
│   ├── activity.g.dart
│   └── displayable_image.dart
│
├── pages/                           # Presentation Layer - Screens
│   ├── auth_page/
│   │   ├── auth_page.dart
│   │   └── widgets/
│   │       └── auth_form.dart
│   ├── home_page/
│   │   └── home_page.dart
│   ├── diagramas_page/
│   │   └── diagramas_page.dart
│   ├── notes_page/
│   │   └── notes_page.dart
│   ├── note_form_page/
│   │   └── note_form_page.dart
│   └── quiz_page/
│       └── quiz_page.dart
│
├── services/                        # Data Layer - Data Access
│   ├── cortes_service.dart
│   ├── diagramas_service.dart
│   ├── notes_service.dart
│   ├── chat_gpt_service.dart
│   ├── activities_service.dart
│   └── user_service.dart
│
├── repositories/                    # Data Layer - Abstractions
│   └── auth_repository.dart
│
├── widgets/                         # Presentation Layer - Reusable Components
│   ├── loading_button.dart
│   ├── interactive_ilustracion.dart
│   └── drag_indicator.dart
│
├── painters/                        # Presentation Layer - Custom Rendering
│   ├── segmento_painter.dart
│   └── vista_painter.dart
│
├── json_converters/                 # Data Layer - Serialization
│   ├── path_converter.dart
│   └── path_list_converter.dart
│
├── extensions/                      # Utilities
│   └── context_extension.dart
│
├── env/                            # Configuration
│   └── env.dart
│
├── main.dart                       # Application Entry Point
├── theme.dart                      # Global Theme Configuration
└── firebase_options.dart           # Firebase Configuration (generated)
```

#### Mapeo a Arquitectura de Tres Capas

| Capa | Directorios | Responsabilidad |
|------|-------------|-----------------|
| **Presentación** | `pages/`, `widgets/`, `painters/` | UI, renderizado, gestos |
| **Lógica de Negocio** | `cubits/` | Estado, eventos, coordinación |
| **Datos** | `models/`, `services/`, `repositories/`, `json_converters/` | Persistencia, API calls, serialización |

#### Convenciones de Nomenclatura

**Archivos**:
- Snake case: `auth_cubit.dart`, `cortes_service.dart`
- Sufijo `.g.dart` para archivos generados

**Clases**:
- Pascal case: `AuthCubit`, `CortesService`, `CorteCerebro`

**Carpetas de Features**:
- Snake case con sufijo indicando tipo: `auth_cubit/`, `home_page/`

#### Archivos Generados

El proyecto utiliza generación de código para reducir boilerplate:

**json_serializable**:
- Genera métodos `fromJson()` y `toJson()` para modelos
- Archivos: `*.g.dart`
- Comando de generación:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

**envied**:
- Genera clase `Env` con variables de entorno
- Archivo: `env/env.dart`
- Lee de: `.env` (no versionado)

**firebase_options**:
- Generado por FlutterFire CLI
- Archivo: `firebase_options.dart`
- Contiene configuración específica de plataforma

### Especificaciones Técnicas

#### Criterios de Ubicación de Código

**¿Dónde crear un nuevo Cubit?**

```
cubits/
└── {feature}_cubit/
    ├── {feature}_cubit.dart
    └── {feature}_state.dart
```

Ejemplo: Para gestionar favoritos, crear `favoritos_cubit/`

**¿Dónde crear un nuevo Service?**

```
services/
└── {feature}_service.dart
```

Ejemplo: Para integración con una API de imágenes médicas, crear `medical_images_service.dart`

**¿Dónde crear un nuevo Model?**

```
models/
├── {model_name}.dart
└── {model_name}.g.dart  # Generado automáticamente
```

Ejemplo: Para representar una estructura anatómica, crear `anatomical_structure.dart`

**¿Dónde crear un Widget reutilizable?**

Si se usa en **una sola página**:
```
pages/{page_name}/widgets/{widget_name}.dart
```

Si se usa en **múltiples páginas**:
```
widgets/{widget_name}.dart
```

**¿Dónde crear una nueva Page?**

```
pages/{page_name}/
└── {page_name}.dart
```

Ejemplo: Para una página de perfil de usuario, crear `pages/profile_page/profile_page.dart`

#### Dependencias entre Directorios

**Reglas de Dependencia**:

```
pages/ → cubits/ → services/ → Firebase/APIs
pages/ → cubits/ → repositories/ → Firebase/APIs
pages/ → widgets/
pages/ → painters/
painters/ → models/
widgets/ → (ninguno, o solo models/)
cubits/ → models/, services/, repositories/
services/ → models/
models/ → json_converters/
```

**Dependencias Prohibidas**:
- `services/` NO debe depender de `cubits/`
- `models/` NO debe depender de `cubits/` o `services/`
- `cubits/` NO debe depender de `pages/` o `widgets/`

### Mejores Prácticas

#### 1. Mantener Alta Cohesión en Features

```
// ✅ CORRECTO: Todo auth junto
cubits/auth_cubit/
  ├── auth_cubit.dart
  └── auth_state.dart

repositories/
  └── auth_repository.dart

pages/auth_page/
  └── auth_page.dart

// ❌ INCORRECTO: Código auth disperso sin patrón claro
```

#### 2. Limitar Alcance de Widgets

```dart
// ✅ Widget específico de página en su carpeta
pages/quiz_page/widgets/question_card.dart

// ❌ Widget específico en widgets/ global
widgets/quiz_question_card.dart  // Solo se usa en quiz_page
```

#### 3. Un Archivo, Una Responsabilidad

```dart
// ✅ CORRECTO: Un archivo por clase principal
// models/note.dart
class Note {
  // ...
}

// ❌ INCORRECTO: Múltiples modelos no relacionados en un archivo
// models/all_models.dart
class Note {}
class Quiz {}
class Diagram {}
```

#### 4. Nombrar Consistentemente

```
// ✅ Patrón consistente
auth_cubit/auth_cubit.dart     → class AuthCubit
cortes_service.dart            → class CortesService
note.dart                      → class Note

// ❌ Inconsistente
auth_cubit/authentication.dart → class AuthCubit
brain_service.dart             → class CortesService
```

### Desafíos Comunes

#### Desafío 1: Imports Excesivos

**Problema**: Archivos con 15+ imports indican acoplamiento excesivo.

**Solución**: Crear archivos barrel (barril) que re-exporten múltiples clases:

```dart
// models/models.dart (barrel file)
export 'corte_cerebro.dart';
export 'segmento_cerebro.dart';
export 'diagrama.dart';
export 'note.dart';
export 'quiz.dart';

// Uso
import 'package:neuroanatomy/models/models.dart';
// Ahora tienes acceso a CorteCerebro, Note, Quiz, etc.
```

#### Desafío 2: Decisión entre Service y Repository

**Pregunta**: ¿Cuándo crear un Service vs Repository?

**Guía**:
- **Repository**: Abstracción sobre fuente de datos que podría cambiar (Auth podría ser Firebase, AWS Cognito, etc.)
- **Service**: Implementación específica de lógica de negocio + acceso a datos

En esta app, AuthRepository es apropiado porque autenticación podría cambiar de proveedor. CortesService es apropiado porque está fuertemente acoplado a Firestore y el esquema de neuroanatomía.

#### Desafío 3: Archivos Generados en Git

**Problema**: ¿Deben los archivos `.g.dart` estar en Git?

**Solución en esta app**: Sí, están versionados porque:
1. Facilita que nuevos desarrolladores no tengan que generar inmediatamente
2. Los PRs muestran cambios en código generado

**Alternativa válida**: Agregar `*.g.dart` a `.gitignore` y generar en CI/CD.

#### Desafío 4: Profundidad de Carpetas

**Problema**: ¿Cuántos niveles de carpetas son apropiados?

**Regla general**:
- 2-3 niveles es ideal
- 4+ niveles dificulta navegación

```
// ✅ Apropiado (2 niveles)
pages/auth_page/widgets/auth_form.dart

// ⚠️ Límite (3 niveles)
pages/home_page/sections/brain_view/brain_canvas.dart

// ❌ Demasiado profundo (4+ niveles)
pages/home_page/sections/brain_view/components/overlays/segment_highlight.dart
```

## Referencias

### Documentación Interna

- [Arquitectura General](./01-app-architecture-overview.md) - Arquitectura de tres capas
- [Patrón BLoC](../bloc-pattern/01-bloc-pattern-fundamentals.md) - Organización de Cubits
- [Flujo de Datos](./03-data-flow.md) - Cómo interactúan las capas

### Referencias Externas

1. **Martin, R. C.** (2008). *Clean Code: A Handbook of Agile Software Craftsmanship*. Prentice Hall. Chapter 10: "Classes".
2. **Fowler, M.** (2002). *Patterns of Enterprise Application Architecture*. Addison-Wesley. Chapter 9: "Organizing Domain Logic".
3. **Soares, P.** (2021). *Flutter Complete Reference*. Alberto Miola. Chapter 4: "Project Structure".
4. **Flutter Style Guide** (2024). https://dart.dev/guides/language/effective-dart/style
5. **Angelov, F.** (2020). BLoC Architecture Recommendations. https://bloclibrary.dev/#/architecture
6. **Vernon, V.** (2013). *Implementing Domain-Driven Design*. Addison-Wesley. Chapter 4: "Architecture".

## Lecturas Adicionales

### Siguientes Pasos

- **03-data-flow.md**: Entender cómo fluyen los datos entre estas carpetas
- **bloc-pattern/01-bloc-pattern-fundamentals.md**: Profundizar en la organización de Cubits
- **features/**: Explorar implementaciones específicas de características

### Temas Avanzados

- **Barrel Files**: Optimizar imports con re-exports
- **Feature-First Organization**: Alternativa organizacional por característica completa
- **Monorepos**: Gestión de múltiples packages en un solo repositorio
- **Code Generation**: Profundizar en build_runner y custom builders
