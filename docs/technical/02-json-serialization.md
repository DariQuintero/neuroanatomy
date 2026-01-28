# Serialización JSON en Flutter

> **Nivel**: Intermedio
> **Prerrequisitos**: Conceptos básicos de Dart, programación orientada a objetos, tipos de datos
> **Tiempo de lectura**: 20-25 minutos

## Introducción

Imagina que necesitas enviar un paquete con varios objetos frágiles a través del correo. No puedes simplemente meter los objetos tal cual en una caja; primero debes envolverlos cuidadosamente, etiquetarlos, y organizarlos de forma que puedan viajar de manera segura. Cuando el paquete llega a su destino, el receptor debe desenvolver cada objeto y reconstruirlos en su forma original.

La serialización JSON funciona exactamente así, pero con datos en lugar de objetos físicos. Cuando tu aplicación de Flutter necesita:
- Guardar datos en Firebase (la base de datos en la nube)
- Recibir información de una API como OpenAI
- Almacenar preferencias del usuario
- Comunicarse con un servidor

Debe convertir los objetos complejos de Dart (como `CorteCerebro` con todos sus segmentos, imágenes y rutas de navegación) en un formato que pueda viajar por Internet: JSON (JavaScript Object Notation).

### ¿Qué es JSON?

JSON es como un lenguaje universal para representar datos. Imagina que tienes una libreta con información de una persona:

```
Nombre: María
Edad: 25
Ciudad: México
Intereses: [Arte, Música, Ciencia]
```

En JSON, esto se escribiría:
```json
{
  "nombre": "María",
  "edad": 25,
  "ciudad": "México",
  "intereses": ["Arte", "Música", "Ciencia"]
}
```

Es texto simple que cualquier sistema puede leer y entender. Los datos están organizados con llaves `{}` para objetos, corchetes `[]` para listas, y cada propiedad tiene un nombre (entre comillas) y un valor.

### El Viaje de los Datos

Piensa en un corte cerebral en esta aplicación. En tu código Flutter, es un objeto rico y complejo:

```dart
CorteCerebro corte = CorteCerebro(
  id: 'corte-1',
  nombre: 'Corte Sagital Medio',
  segmentos: [...],  // Lista de segmentos con paths SVG
  realImage: 'url-imagen-real',
  vistas: [...]
);
```

Pero Firebase no entiende objetos de Dart. Solo entiende documentos JSON. Entonces ocurre esta transformación:

**Serialización** (Objeto Dart → JSON):
```
CorteCerebro → toJson() → {"id": "corte-1", "nombre": "Corte Sagital Medio", ...}
```

**Deserialización** (JSON → Objeto Dart):
```
{"id": "corte-1", "nombre": "Corte Sagital Medio", ...} → fromJson() → CorteCerebro
```

Es un proceso de ida y vuelta continuo. Cuando cargas datos desde Firebase, se deserializan. Cuando guardas notas del usuario, se serializan.

### Los Dos Métodos Mágicos

Cada modelo en la aplicación tiene dos métodos cruciales:

**fromJson**: Reconstruye un objeto Dart desde JSON (como desarmar el paquete)
```dart
factory CorteCerebro.fromJson(Map<String, dynamic> json)
```

**toJson**: Convierte un objeto Dart a JSON (como empacar el paquete)
```dart
Map<String, dynamic> toJson()
```

Estos métodos actúan como traductores bidireccionales entre el mundo de Dart y el mundo de JSON.

### El Desafío: Objetos Anidados

Ahora imagina que tu paquete contiene una caja, y dentro de esa caja hay otras cajas más pequeñas, y dentro de esas hay objetos. Cada caja debe empacarse y desempacarse en orden correcto.

Un `CorteCerebro` no es solo datos simples. Contiene:
- Una lista de `SegmentoCerebro` (cada uno con sus propios datos)
- Cada `SegmentoCerebro` contiene rutas SVG (representadas como objetos `Path` de Flutter)
- Las rutas SVG son cadenas de texto complejas que deben convertirse en objetos gráficos

Es como muñecas rusas (matrioshkas): objetos dentro de objetos dentro de objetos. Cada nivel debe saber cómo empacarse y desempacarse.

### Automatización con json_serializable

Escribir métodos `fromJson` y `toJson` manualmente para cada modelo sería tedioso y propenso a errores. Sería como empacar cientos de paquetes a mano cuando podrías tener una máquina que lo haga automáticamente.

La biblioteca `json_serializable` es esa máquina. Tú solo le dices:
- "Esta clase necesita serialización" (con `@JsonSerializable()`)
- "Este campo tiene un nombre especial en JSON" (con `@JsonKey()`)
- "Este campo necesita conversión especial" (con convertidores personalizados)

Y la biblioteca genera automáticamente todo el código de serialización por ti en archivos `.g.dart` (la "g" significa "generado").

---

## Documentación Técnica Formal

### Fundamento Teórico

La serialización es el proceso de convertir estructuras de datos en memoria a un formato que puede ser almacenado o transmitido y posteriormente reconstruido. En el contexto de aplicaciones Flutter que interactúan con APIs REST y bases de datos NoSQL como Cloud Firestore, JSON (JavaScript Object Notation, RFC 8259) es el formato de serialización estándar debido a su simplicidad, legibilidad y amplio soporte en diferentes plataformas.

JSON es un formato de intercambio de datos basado en texto que representa estructuras mediante dos construcciones fundamentales:
1. **Objetos**: Colecciones desordenadas de pares clave-valor, representados por `{}`
2. **Arrays**: Listas ordenadas de valores, representados por `[]`

Los valores pueden ser: strings, números, booleanos, null, objetos u arrays (estructuras recursivas).

#### Serialización vs Deserialización

- **Serialización**: Conversión de objetos en memoria a representación JSON (marshalling)
- **Deserialización**: Conversión de representación JSON a objetos en memoria (unmarshalling)

```
Dart Object → (Serialization) → JSON String → (Network/Storage) → JSON String → (Deserialization) → Dart Object
```

#### Desafíos de la Serialización en Dart

Dart es un lenguaje de tipado fuerte (strongly typed), mientras que JSON es dinámicamente tipado. Esta discrepancia de tipos presenta desafíos:

1. **Type Safety**: Los valores JSON son `dynamic`, perdiendo las garantías de tipo en tiempo de compilación
2. **Null Safety**: Dart moderno requiere manejo explícito de nulabilidad, JSON permite null libremente
3. **Tipos Complejos**: Tipos específicos de Dart (DateTime, Path, enums) no tienen representación directa en JSON
4. **Validación**: JSON puede contener datos malformados o inconsistentes que deben validarse

### Implementación en la Aplicación NeuroAnatomía

Esta aplicación utiliza el paquete `json_serializable` para generar código de serialización automáticamente mediante source generation (generación de código en tiempo de compilación).

#### Arquitectura de Serialización

El proceso de serialización en la aplicación sigue este flujo:

```
1. Definición de modelo con anotaciones
2. Ejecución de build_runner para generar código
3. Uso de fromJson/toJson en tiempo de ejecución
```

#### Modelo Base: CorteCerebro

El modelo `CorteCerebro` representa un corte del cerebro con toda su información asociada:

```dart
// /lib/models/corte_cerebro.dart:10-62
@JsonSerializable()
class CorteCerebro extends Equatable {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @JsonKey()
  final String realImage;

  @JsonKey()
  final String? aquarelaImage;

  @JsonKey()
  final List<SegmentoCerebro> segmentos;

  @JsonKey(defaultValue: [])
  final List<VistaCerebro> vistas;

  @JsonKey()
  final String? derechaId;

  @JsonKey()
  final String? izquierdaId;

  @JsonKey()
  final String? arribaId;

  @JsonKey()
  final String? abajoId;

  @JsonKey()
  final String? atrasId;

  const CorteCerebro({
    required this.id,
    required this.nombre,
    required this.segmentos,
    required this.realImage,
    required this.vistas,
    this.aquarelaImage,
    this.derechaId,
    this.izquierdaId,
    this.arribaId,
    this.abajoId,
    this.atrasId,
  });

  factory CorteCerebro.fromJson(Map<String, dynamic> json) =>
      _$CorteCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$CorteCerebroToJson(this);
}
```

**Análisis técnico:**

1. **@JsonSerializable()**: Anotación que indica a `json_serializable` que genere código de serialización para esta clase
2. **@JsonKey()**: Marca cada campo para ser incluido en la serialización
3. **@JsonKey(defaultValue: [])**: Especifica un valor por defecto si el campo está ausente en JSON
4. **Tipos nullable (?)**: `aquarelaImage`, `derechaId`, etc. son opcionales, reflejando que no todos los cortes tienen imagen acuarela o todas las direcciones de navegación
5. **List\<SegmentoCerebro\>**: Tipo complejo anidado que requiere que `SegmentoCerebro` también sea serializable
6. **factory constructor**: Patrón factory para construir instancias desde JSON
7. **Delegación a código generado**: `_$CorteCerebroFromJson` y `_$CorteCerebroToJson` son funciones generadas automáticamente

El archivo generado (`corte_cerebro.g.dart`) contiene la implementación real:

```dart
// Generado automáticamente
CorteCerebro _$CorteCerebroFromJson(Map<String, dynamic> json) => CorteCerebro(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  segmentos: (json['segmentos'] as List<dynamic>)
      .map((e) => SegmentoCerebro.fromJson(e as Map<String, dynamic>))
      .toList(),
  realImage: json['realImage'] as String,
  vistas: (json['vistas'] as List<dynamic>?)
          ?.map((e) => VistaCerebro.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  aquarelaImage: json['aquarelaImage'] as String?,
  derechaId: json['derechaId'] as String?,
  // ... etc
);
```

#### Serialización Anidada: SegmentoCerebro

```dart
// /lib/models/segmento_cerebro.dart:9-40
@JsonSerializable()
class SegmentoCerebro extends Equatable {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @SvgPathListConverter()
  final List<Path> path;

  const SegmentoCerebro({
    required this.id,
    required this.nombre,
    required this.path,
  });

  factory SegmentoCerebro.fromJson(Map<String, dynamic> json) =>
      _$SegmentoCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentoCerebroToJson(this);

  @override
  List<Object?> get props => [id, nombre, path];
}
```

**Punto clave**: El campo `path` es de tipo `List<Path>`, donde `Path` es una clase de Flutter para gráficos vectoriales. Este tipo no tiene representación JSON natural, por lo que requiere un **convertidor personalizado**.

#### Convertidores Personalizados: PathConverter

Los convertidores personalizados (custom JSON converters) permiten definir cómo serializar y deserializar tipos que no tienen mapeo directo a JSON.

```dart
// /lib/json_converters/path_converter.dart:1-16
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class SvgPathConverter implements JsonConverter<Path, String?> {
  const SvgPathConverter();

  @override
  Path fromJson(String? path) {
    if (path == null) return Path();
    return parseSvgPath(path);
  }

  @override
  String? toJson(Path object) => null;
}
```

**Análisis técnico:**

1. **Implementa JsonConverter\<Path, String?\>**: Interface genérica donde:
   - `Path`: Tipo en Dart (en memoria)
   - `String?`: Tipo en JSON (serializado)

2. **fromJson(String? path)**: Deserialización
   - Recibe un string SVG path (ej: "M10 10 L20 20 Z")
   - Usa `parseSvgPath()` de la biblioteca `svg_path_parser` para convertirlo a objeto `Path` de Flutter
   - Retorna `Path()` vacío si el input es null (manejo de null safety)

3. **toJson(Path object)**: Serialización
   - Retorna `null` porque esta aplicación solo lee paths desde Firestore, nunca los escribe
   - En una implementación completa, convertiría el `Path` de vuelta a string SVG

4. **Uso en modelo**: `@SvgPathListConverter()` en `SegmentoCerebro.path` indica que cada elemento de la lista debe procesarse con este convertidor

#### El Proceso de Build

Para generar el código de serialización, se ejecuta:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando:
1. Analiza todos los archivos Dart buscando anotaciones `@JsonSerializable`
2. Genera archivos `.g.dart` correspondientes con código de serialización
3. `--delete-conflicting-outputs` elimina archivos generados anteriores para evitar conflictos

### Ejemplos de Código

#### Deserialización en Servicios

Cuando `CortesService` carga datos desde Firestore:

```dart
Future<List<CorteCerebro>> getCortes() async {
  final cortesSnapshot = await _firestore.collection('cortes').get();

  return cortesSnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;  // Inyectar el ID del documento
    return CorteCerebro.fromJson(data);  // Deserializar
  }).toList();
}
```

El proceso:
1. `doc.data()` retorna `Map<String, dynamic>` (JSON crudo de Firestore)
2. Se añade el ID del documento al mapa
3. `CorteCerebro.fromJson(data)` construye el objeto Dart completo
4. Internamente, deserializa listas anidadas de `SegmentoCerebro` y `VistaCerebro`
5. Cada `SegmentoCerebro` usa `SvgPathConverter` para convertir strings SVG a objetos `Path`

#### Serialización al Guardar Datos

Cuando se guarda una nota del usuario:

```dart
Future<void> createNote(Note note) async {
  await _firestore
    .collection('users')
    .doc(userId)
    .collection('structures')
    .doc(structureId)
    .collection('notes')
    .add(note.toJson());  // Serializar a Map<String, dynamic>
}
```

### Especificaciones Técnicas

#### Tipos de Datos JSON y Mapeo a Dart

| JSON Type | Dart Type | Notas |
|-----------|-----------|-------|
| string | String | Mapeo directo |
| number | int, double | json_serializable infiere el tipo |
| boolean | bool | Mapeo directo |
| null | null | Requiere tipos nullable en Dart 2.12+ |
| array | List\<T\> | Requiere tipo genérico para deserialización |
| object | Map\<String, dynamic\> o clase personalizada | |

#### Anotaciones de json_serializable

**@JsonSerializable()**
```dart
@JsonSerializable(
  explicitToJson: true,  // Llama toJson() en objetos anidados
  fieldRename: FieldRename.snake,  // Convierte camelCase a snake_case
  includeIfNull: false,  // Omite campos null en toJson()
)
```

**@JsonKey()**
```dart
@JsonKey(
  name: 'custom_name',  // Mapea a nombre diferente en JSON
  defaultValue: 'default',  // Valor si falta en JSON
  required: true,  // Lanza excepción si falta
  ignore: true,  // No serializa este campo
  fromJson: customFromJson,  // Función personalizada de deserialización
  toJson: customToJson,  // Función personalizada de serialización
)
```

#### Manejo de Enums

```dart
// /lib/models/corte_cerebro.dart:8
enum ImageMode { real, aquarela }
```

Los enums se serializan automáticamente como strings:
```json
{"imageMode": "real"}
```

Si se necesita control sobre la representación, se puede usar `@JsonValue`:

```dart
enum Status {
  @JsonValue(0) pending,
  @JsonValue(1) active,
  @JsonValue(2) completed
}
```

### Mejores Prácticas

1. **Use const constructors cuando sea posible**: Mejora el rendimiento y permite uso en contextos const
   ```dart
   const CorteCerebro({required this.id, ...});
   ```

2. **Implemente Equatable para comparaciones eficientes**: Permite comparar objetos por valor en lugar de referencia
   ```dart
   class CorteCerebro extends Equatable {
     @override
     List<Object?> get props => [id, nombre, segmentos, ...];
   }
   ```

3. **Maneje explícitamente la nulabilidad**: Use `?` para campos opcionales y `required` para campos obligatorios
   ```dart
   final String nombre;  // No null
   final String? aquarelaImage;  // Puede ser null
   ```

4. **Valide datos después de deserializar**: JSON puede contener datos inválidos
   ```dart
   factory CorteCerebro.fromJson(Map<String, dynamic> json) {
     final corte = _$CorteCerebroFromJson(json);
     if (corte.segmentos.isEmpty) {
       throw FormatException('Corte must have at least one segment');
     }
     return corte;
   }
   ```

5. **Use defaultValue para campos que pueden faltar**: Evita errores si el esquema JSON cambia
   ```dart
   @JsonKey(defaultValue: [])
   final List<VistaCerebro> vistas;
   ```

6. **Separe modelos de negocio de modelos de API**: Si la estructura JSON no coincide con su modelo de dominio ideal, use clases de transferencia de datos (DTOs) intermedias

7. **Regenere código después de cambios**: Siempre ejecute `build_runner` después de modificar modelos
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Desafíos Comunes

#### 1. Olvidar generar código después de cambios

**Síntoma**: Errores de compilación indicando que `_$NombreClaseFromJson` no existe

**Solución**: Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

#### 2. Tipos anidados no serializables

**Problema**:
```dart
@JsonSerializable()
class Modelo {
  final ClaseNoSerializable objeto;  // Error
}
```

**Solución**: Asegurarse de que `ClaseNoSerializable` también tenga `@JsonSerializable()` y métodos fromJson/toJson

#### 3. Campos con nombres diferentes en JSON y Dart

**Problema**: API usa `user_name` pero Dart usa `userName`

**Solución**:
```dart
@JsonKey(name: 'user_name')
final String userName;
```

O usar `fieldRename` global:
```dart
@JsonSerializable(fieldRename: FieldRename.snake)
```

#### 4. Tipos personalizados sin convertidor

**Problema**: `Path`, `DateTime` personalizados, enums complejos

**Solución**: Implementar `JsonConverter`:
```dart
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
```

#### 5. Listas heterogéneas

JSON permite arrays con tipos mixtos:
```json
{"items": [1, "string", true, {"key": "value"}]}
```

Esto no tiene equivalente directo en Dart tipado. **Solución**: Rediseñar el esquema JSON o usar `List<dynamic>` (perdiendo type safety).

## Referencias

### Documentación Interna
- [Data Flow](/docs/architecture/03-data-flow.md) - Cómo fluyen los datos serializados a través de la aplicación
- [Services and Repositories](/docs/firebase/04-services-and-repositories.md) - Donde ocurre serialización/deserialización
- [Cloud Firestore](/docs/firebase/03-cloud-firestore.md) - Estructura de datos JSON en Firestore

### Referencias Externas
1. Dart Team (2024). "JSON and serialization". https://docs.flutter.dev/data-and-backend/serialization/json
2. json_serializable Package. https://pub.dev/packages/json_serializable
3. ECMA-404 (2017). "The JSON Data Interchange Standard". https://www.json.org/
4. Bray, T. (Ed.) (2017). "RFC 8259: The JavaScript Object Notation (JSON) Data Interchange Format". IETF.
5. Soares, P. (2021). "Flutter Complete Reference". Alberto Miola. Chapter 9: Working with JSON.
6. W3C (2018). "Scalable Vector Graphics (SVG) 2 Specification". https://www.w3.org/TR/SVG2/ - Para entender paths SVG

## Lecturas Adicionales

- [Async Programming](/docs/technical/01-async-programming.md) - Serialización en contextos asíncronos (Future\<T\>)
- [Custom Painting and SVG](/docs/features/02-custom-painting-and-svg.md) - Cómo se usan los paths SVG deserializados
- [App Architecture Overview](/docs/architecture/01-app-architecture-overview.md) - Rol de modelos en la arquitectura
- [AI Quiz Generation](/docs/features/04-ai-quiz-generation.md) - Deserialización de respuestas JSON de OpenAI
