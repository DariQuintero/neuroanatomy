# Guía de Estructura de Base de Datos Firestore

## Descripción General

Este documento proporciona una guía completa de la estructura de la base de datos Firestore utilizada en la aplicación NeuroAnatomy. La base de datos contiene tres colecciones principales que permiten la funcionalidad de la aplicación:

- **cortes**: Vistas y cortes transversales del cerebro con regiones anatómicas interactivas
- **diagramas**: Diagramas anatómicos de vías y estructuras neurológicas
- **users**: Datos específicos de cada usuario incluyendo notas y actividades de estudio

---

## Colección: cortes

### Descripción

La colección `cortes` es el corazón de la funcionalidad interactiva de la aplicación. Cada documento representa una vista o corte específico del cerebro (frontal, lateral, medial, ventral, etc.) que el usuario puede explorar visualmente.

**Funcionalidad en la app:**
- Cuando el usuario abre un corte, la aplicación muestra la imagen anatómica correspondiente
- Las regiones definidas en la subcolección `segmentos` se vuelven interactivas
- El usuario puede tocar diferentes áreas del cerebro para identificar estructuras
- Los botones de navegación permiten "moverse" entre diferentes vistas del cerebro en 3D

### Estructura del Documento

Cada documento en `cortes` tiene los siguientes campos:

#### Campo: id

**Tipo:** String
**Requerido:** Sí
**Formato:** snake_case (minúsculas con guiones bajos)

**Propósito:**
Este campo es el identificador único del corte que se usa para la navegación entre vistas. Es diferente del Document ID autogenerado por Firestore.

**Cómo funciona en la app:**
- Cuando un corte tiene un campo de navegación (ej: `derechaId: "hemisferio_derecho"`), la app busca el documento donde `id == "hemisferio_derecho"`
- Este sistema permite crear enlaces entre cortes sin depender de los IDs autogenerados de Firestore
- El valor debe ser descriptivo de la vista anatómica que representa

**Ejemplo:**
```json
"id": "hemisferio_derecho"
```

**Valores típicos:**
- `"frontal"` - Vista frontal del cerebro
- `"hemisferio_derecho"` - Hemisferio derecho vista lateral
- `"medial_izquierdo"` - Hemisferio izquierdo vista medial
- `"ventral"` - Vista inferior del cerebro
- `"posterior"` - Vista posterior del cerebro

---

#### Campo: nombre

**Tipo:** String
**Requerido:** Sí

**Propósito:**
El nombre legible que se muestra al usuario en la interfaz de la aplicación.

**Cómo funciona en la app:**
- Se muestra como título en la parte superior de la pantalla cuando el usuario está viendo ese corte
- Aparece en listas de selección de cortes
- Se usa en el historial de navegación del usuario

**Ejemplo:**
```json
"nombre": "Hemisferio Derecho"
```

**Características:**
- Debe ser en español
- Puede incluir espacios y mayúsculas
- Debe ser claro y descriptivo para usuarios no técnicos

---

#### Campo: realImage

**Tipo:** String (URL)
**Requerido:** Sí

**Propósito:**
URL de la imagen anatómica realista del corte cerebral almacenada en Firebase Storage.

**Cómo funciona en la app:**
- Esta es la imagen principal que se muestra cuando el usuario selecciona el corte
- La aplicación carga esta imagen y sobre ella renderiza las regiones interactivas (segmentos)
- Las coordenadas de los paths de segmentos están calibradas para esta imagen específica

**Ejemplo:**
```json
"realImage": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/cortes%2FcorteFrontal.png?alt=media&token=abc123..."
```

**Requisitos técnicos:**
- Formato: PNG o JPG
- Resolución recomendada: Al menos 1000px en el lado más largo
- La imagen debe estar subida en Firebase Storage en la carpeta `cortes/`
- El URL debe incluir el token de acceso (`?alt=media&token=...`)

---

#### Campo: aquarelaImage

**Tipo:** String (URL)
**Requerido:** No (opcional)

**Propósito:**
URL de una versión estilizada de la imagen en estilo acuarela o ilustración artística.

**Cómo funciona en la app:**
- Cuando este campo existe, la aplicación puede ofrecer un botón para alternar entre la vista realista y la vista ilustrada
- Permite a los usuarios ver representaciones más simplificadas o artísticas de la anatomía
- Útil para fines educativos donde colores y simplificación ayudan al aprendizaje

**Ejemplo:**
```json
"aquarelaImage": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/cortes%2FcorteFrontalAcuarela.png?alt=media&token=xyz789..."
```

**Nota importante:**
- Esta imagen debe tener exactamente las mismas dimensiones que `realImage`
- Los segmentos interactivos se renderizarán en la misma posición en ambas imágenes

---

#### Campos de Navegación

Los siguientes seis campos permiten crear un sistema de navegación 3D entre diferentes vistas del cerebro:

##### adelanteId, atrasId, arribaId, abajoId, derechaId, izquierdaId

**Tipo:** String
**Requerido:** No (cada corte puede tener 0 a 6 conexiones)
**Formato:** Debe coincidir con el campo `id` de otro corte

**Propósito:**
Estos campos crean las conexiones de navegación entre diferentes vistas del cerebro, permitiendo al usuario "moverse" espacialmente como si rotara un modelo 3D.

**Cómo funciona en la app:**

1. **Renderizado de botones:**
   - Si un corte tiene `derechaId: "hemisferio_izquierdo"`, la app muestra una flecha hacia la derecha
   - Al tocar esa flecha, la app busca el documento donde `id == "hemisferio_izquierdo"` y lo carga

2. **Lógica espacial:**
   - `adelanteId`: Muestra qué vista aparece si "avanzas" hacia el frente
   - `atrasId`: Muestra qué vista aparece si retrocedes
   - `arribaId`: Vista que aparece si miras hacia arriba
   - `abajoId`: Vista que aparece si miras hacia abajo
   - `derechaId`: Vista que aparece si rotas a la derecha
   - `izquierdaId`: Vista que aparece si rotas a la izquierda

3. **Construcción mental 3D:**
   - El usuario puede mentalmente reconstruir la estructura 3D del cerebro navegando entre vistas
   - Las conexiones deben ser lógicamente consistentes desde una perspectiva anatómica

**Ejemplo completo de navegación:**

```json
{
  "id": "frontal",
  "nombre": "Vista Frontal",
  "realImage": "...",
  "abajoId": "ventral",
  "derechaId": "hemisferio_izquierdo",
  "izquierdaId": "hemisferio_derecho"
}
```

En este ejemplo:
- El usuario está viendo la cara frontal del cerebro
- Si presiona la flecha hacia abajo, verá la vista ventral (inferior)
- Si presiona la flecha derecha, verá el hemisferio izquierdo (porque está viendo desde fuera, su derecha es el hemisferio izquierdo del cerebro)
- Si presiona la flecha izquierda, verá el hemisferio derecho

**Importante:**
- Los valores deben ser exactamente iguales al campo `id` del corte de destino (no el Document ID de Firestore)
- Si un corte no tiene conexión en una dirección, simplemente no incluyas ese campo
- Las conexiones no necesitan ser bidireccionales (el corte A puede apuntar al corte B, pero B no necesariamente debe apuntar de vuelta a A)

---

### Ejemplo Completo de Documento Corte

```json
{
  "id": "hemisferio_derecho",
  "nombre": "Hemisferio Derecho - Vista Lateral",
  "realImage": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/cortes%2FhemisferioDerecho.png?alt=media&token=abc123",
  "aquarelaImage": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/cortes%2FhemisferioDerechoAcuarela.png?alt=media&token=def456",
  "derechaId": "frontal",
  "izquierdaId": "posterior",
  "arribaId": "dorsal",
  "abajoId": "ventral"
}
```

**Explicación del ejemplo:**
- Este corte muestra el hemisferio derecho desde el lado externo
- Tiene una imagen realista y una versión acuarela
- Está conectado a 4 vistas diferentes
- Cuando el usuario presiona "derecha", rotará hacia la vista frontal
- Cuando presiona "izquierda", rotará hacia la vista posterior
- Cuando mira "arriba", verá la vista superior (dorsal)
- Cuando mira "abajo", verá la vista inferior (ventral)

---

### Subcolección: segmentos

**Ruta:** `cortes/{corteId}/segmentos/{segmentoId}`

Esta subcolección define las regiones anatómicas interactivas dentro de cada corte cerebral. Cada segmento representa una estructura anatómica específica (corteza motora, hipocampo, tálamo, etc.) que el usuario puede identificar y estudiar.

#### Estructura del Documento Segmento

##### Campo: id

**Tipo:** String
**Requerido:** Sí
**Formato:** snake_case

**Propósito:**
Identificador único de la estructura anatómica que representa este segmento.

**Cómo funciona en la app:**
- Se usa para referenciar esta estructura en el sistema de notas del usuario
- Cuando un usuario crea una nota sobre "corteza_motora", ese `id` conecta la nota con este segmento
- Permite rastrear qué estructuras ha estudiado el usuario

**Ejemplo:**
```json
"id": "corteza_prefrontal"
```

**Valores típicos:**
- `"corteza_motora"` - Corteza motora primaria
- `"hipocampo"` - Hipocampo
- `"talamo"` - Tálamo
- `"cuerpo_calloso"` - Cuerpo calloso
- `"amigdala"` - Amígdala

---

##### Campo: nombre

**Tipo:** String
**Requerido:** Sí

**Propósito:**
Nombre legible de la estructura anatómica que se muestra al usuario.

**Cómo funciona en la app:**
- Cuando el usuario toca una región del cerebro, aparece un tooltip o modal mostrando este nombre
- Se muestra en listas de estructuras estudiadas
- Aparece en el sistema de notas del usuario

**Ejemplo:**
```json
"nombre": "Corteza Prefrontal"
```

**Características:**
- Español médico/anatómico correcto
- Mayúsculas apropiadas
- Claro y específico

---

##### Campo: path

**Tipo:** Array de Strings
**Requerido:** Sí

**Propósito:**
Define la forma y ubicación exacta de la región interactiva sobre la imagen del corte mediante comandos SVG path.

**Cómo funciona en la app:**

1. **Renderización:**
   - La app carga la imagen del corte (`realImage` o `aquarelaImage`)
   - Lee los comandos SVG de este campo
   - Dibuja una región invisible sobre la imagen en la forma especificada

2. **Interactividad:**
   - Cuando el usuario toca dentro del área definida por este path, la app detecta que tocó esta estructura
   - La región puede iluminarse o resaltarse en un color (ej: verde semitransparente)
   - Se muestra el `nombre` de la estructura

3. **Coordinación con imagen:**
   - Las coordenadas en el path son píxeles relativos a la esquina superior izquierda de la imagen
   - Cada par de números representa un punto (x, y) en la imagen
   - El path debe estar calibrado exactamente para la imagen específica del corte

**Formato del path SVG:**

El path está compuesto por comandos que definen la forma:

- **M x y** - Move to (mover a): Mueve el "lápiz" a las coordenadas (x, y) sin dibujar
- **L x y** - Line to (línea a): Dibuja una línea recta hasta (x, y)
- **C x1 y1 x2 y2 x y** - Curve to (curva a): Dibuja una curva Bézier usando puntos de control
- **Z** - Close path (cerrar): Cierra la figura conectando el último punto con el primero

**Ejemplo:**
```json
"path": [
  "M 435.359 344.108 C 452.56 393.108 469.76 447.027 486.961 505.866 C 489.733 515.348 497.931 509.616 511.555 488.67 C 520.179 475.41 533.764 467.307 552.308 464.359 L 625.079 314.701 L 482.858 330.195 Z"
]
```

**Desglose del ejemplo:**
- `M 435.359 344.108` - Comienza en el píxel (435, 344) de la imagen
- `C 452.56 393.108 469.76 447.027 486.961 505.866` - Dibuja una curva suave
- `L 625.079 314.701` - Dibuja una línea recta al punto (625, 314)
- `Z` - Cierra la forma conectando de vuelta al punto inicial

**Nota importante:**
- El array normalmente contiene solo un string, pero técnicamente puede tener múltiples si la región tiene partes discontinuas
- Cada path debe formar una región cerrada para que la detección de toque funcione correctamente

---

#### Ejemplo Completo de Documento Segmento

```json
{
  "id": "corteza_motora",
  "nombre": "Corteza Motora Primaria",
  "path": [
    "M 662.47 444.693 L 625.117 403.211 L 653.272 358.969 L 678.712 309.393 L 765.487 307.709 L 770.002 349.333 L 819.778 412.332 L 774.098 398.567 L 745.407 379.274 C 740.787 392.301 736.166 405.458 731.546 418.743 C 726.301 433.824 739.462 442.642 771.027 445.196 Z"
  ]
}
```

**Explicación del ejemplo:**
- Este segmento representa la corteza motora primaria
- El path define un polígono con curvas que delimita la ubicación de esta estructura en la imagen del corte
- Cuando el usuario toca dentro de esta área en la pantalla, la app muestra "Corteza Motora Primaria" y puede resaltar la región en verde

---

#### Creando Paths SVG para Nuevos Segmentos

**Herramientas recomendadas:**
1. **Inkscape** (gratis, open source): https://inkscape.org
2. **Adobe Illustrator** (de pago)
3. **Figma** (gratis para uso básico)

**Proceso:**

1. **Importar imagen:**
   - Abre la imagen del corte en tu software de vectores
   - Asegúrate de conocer las dimensiones exactas en píxeles

2. **Trazar estructura:**
   - Usa la herramienta "Bezier" o "Pluma" para trazar el contorno de la estructura anatómica
   - Sé preciso pero no necesitas perfección absoluta
   - Cierra el path completamente

3. **Exportar path:**
   - Selecciona la forma que creaste
   - Copia el atributo `d` del elemento `<path>` en el SVG
   - Ese string es lo que va en el campo `path`

4. **Verificar en la app:**
   - Agrega el segmento a Firestore
   - Abre la app y verifica que el área toque funcione correctamente
   - Ajusta si es necesario

---

### Subcolección: vistas

**Ruta:** `cortes/{corteId}/vistas/{vistaId}`

Esta subcolección está diseñada para almacenar vistas alternativas o niveles de zoom del mismo corte, aunque actualmente no está en uso activo en la aplicación.

**Uso potencial futuro:**
- Almacenar versiones de diferentes niveles de zoom (general, detallado, microscópico)
- Guardar anotaciones o overlays específicos para diferentes propósitos educativos
- Versiones del mismo corte con diferentes etiquetados

La estructura de los documentos en esta subcolección sería similar a los segmentos pero adaptada para el propósito específico de las vistas alternativas.

---

### Agregando un Nuevo Corte

#### Paso 1: Preparar las Imágenes

1. **Obtener o crear imagen anatómica:**
   - Foto de espécimen real
   - Ilustración médica
   - Render 3D de modelo anatómico
   - Resolución mínima: 1000px
   - Formato: PNG (preferido) o JPG

2. **Opcional: Crear versión acuarela:**
   - Procesar la imagen en estilo ilustrado
   - Mantener exactamente las mismas dimensiones
   - Simplificar colores si es necesario

3. **Subir a Firebase Storage:**
   - Ir a Firebase Console → Storage
   - Crear/usar carpeta `cortes/`
   - Subir imagen(es)
   - Copiar las URLs completas (con token)

#### Paso 2: Crear el Documento en Firestore

1. **Ir a Firebase Console → Firestore Database**
2. **Entrar a la colección `cortes`**
3. **Hacer clic en "Add document"**
4. **Dejar que Firestore genere el Document ID automáticamente**
5. **Agregar los campos:**

```json
{
  "id": "coronal_anterior",
  "nombre": "Corte Coronal Anterior",
  "realImage": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/cortes%2Fcoronal_ant.png?alt=media&token=...",
  "aquarelaImage": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/cortes%2Fcoronal_ant_acua.png?alt=media&token=...",
  "atrasId": "coronal_medio",
  "adelanteId": "frontal"
}
```

#### Paso 3: Agregar Segmentos

1. **Trazar regiones anatómicas** usando Inkscape o similar (ver sección anterior)
2. **Para cada estructura anatómica:**
   - Entrar al documento del corte en Firestore
   - Ir a la subcolección `segmentos`
   - Agregar un nuevo documento
   - Dejar que Firestore genere el ID automáticamente

```json
{
  "id": "nucleo_caudado",
  "nombre": "Núcleo Caudado",
  "path": [
    "M 234.5 123.8 L 245.2 134.1 C 256.3 145.2 267.4 156.3 278.5 167.4 L 290.1 180.2 Z"
  ]
}
```

#### Paso 4: Conectar con Navegación

1. **Determinar qué vistas conectan** con tu nuevo corte
2. **Actualizar los cortes existentes:**
   - Si tu corte está "a la derecha" del corte frontal, edita el documento frontal
   - Agrega `derechaId: "coronal_anterior"` (usando el `id` de tu nuevo corte)

3. **Verificar consistencia:**
   - Las conexiones deben tener sentido anatómico
   - Prueba en la app que la navegación fluya lógicamente

---

## Colección: diagramas

### Descripción

La colección `diagramas` contiene ilustraciones de vías neurológicas, estructuras anatómicas complejas y diagramas esquemáticos que complementan los cortes interactivos. A diferencia de los cortes, estos son imágenes estáticas sin segmentación interactiva.

**Funcionalidad en la app:**
- Los usuarios pueden navegar a una sección de diagramas
- Pueden ver ilustraciones de vías como el tracto corticoespinal
- Pueden estudiar estructuras complejas como la amígdala en detalle
- Los diagramas se pueden categorizar por tipo (vías vs estructuras)
- Los usuarios pueden crear notas asociadas a cada diagrama

---

### Estructura del Documento

#### Campo: nombre

**Tipo:** String
**Requerido:** Sí

**Propósito:**
Nombre del diagrama que se muestra al usuario.

**Cómo funciona en la app:**
- Se muestra como título cuando el usuario abre el diagrama
- Aparece en listas y búsquedas de diagramas
- Se usa para filtrar y organizar el contenido

**Ejemplo:**
```json
"nombre": "Tracto Corticoespinal"
```

---

#### Campo: type

**Tipo:** String
**Requerido:** Sí
**Valores permitidos:** `"via"` o `"estructura"`

**Propósito:**
Categoriza el diagrama según su contenido educativo.

**Cómo funciona en la app:**

1. **Organización visual:**
   - La app puede mostrar tabs o secciones separadas: "Vías" y "Estructuras"
   - Los usuarios pueden filtrar para ver solo vías o solo estructuras

2. **Contexto educativo:**
   - **"via"**: Indica que el diagrama muestra un tracto o camino neural
     - Ejemplos: tracto corticoespinal, vía espinotalámica, fascículo arqueado
     - Típicamente muestran el recorrido de señales nerviosas

   - **"estructura"**: Indica que el diagrama muestra la anatomía de una región específica
     - Ejemplos: tálamo, amígdala, cerebelo
     - Típicamente muestran la organización interna o conexiones de una estructura

**Ejemplo:**
```json
"type": "via"
```

**Importante:**
- Debe ser exactamente `"via"` o `"estructura"` (singular, minúsculas)
- La app puede romper si se usan otros valores

---

#### Campo: imageUrl

**Tipo:** String (URL)
**Requerido:** Sí

**Propósito:**
URL de la imagen del diagrama almacenada en Firebase Storage.

**Cómo funciona en la app:**
- Esta imagen se muestra a pantalla completa cuando el usuario selecciona el diagrama
- El usuario puede hacer zoom para ver detalles
- La imagen debe ser clara y etiquetada

**Ejemplo:**
```json
"imageUrl": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/diagramas%2Fcorticoespinal.png?alt=media&token=abc123..."
```

**Requisitos de la imagen:**
- **Formato:** PNG (preferido para diagramas) o JPG
- **Resolución:** Mínimo 1200px en el lado más largo
- **Etiquetado:** La imagen debe incluir etiquetas y flechas claras
- **Idioma:** Etiquetas en español
- **Claridad:** Colores contrastantes, texto legible

---

### Ejemplo Completo de Documento Diagrama

```json
{
  "nombre": "Vía Espinotalámica Lateral",
  "type": "via",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/diagramas%2Fespinotalamico_lateral.png?alt=media&token=xyz789"
}
```

**Explicación del ejemplo:**
- Este diagrama muestra la vía espinotalámica lateral (dolor y temperatura)
- Es categorizado como "via" porque muestra un tracto neural
- La imagen incluye etiquetas mostrando: receptores periféricos → médula espinal → decusación → tálamo → corteza somatosensorial

---

### Agregando un Nuevo Diagrama

#### Paso 1: Crear o Obtener el Diagrama

**Opciones:**

1. **Crear desde cero:**
   - Usa software como Inkscape, Illustrator, o PowerPoint
   - Dibuja la vía o estructura con flechas y etiquetas
   - Exporta como PNG de alta resolución

2. **Modificar diagrama existente:**
   - Toma un diagrama de libro de texto o recurso libre
   - Traduce etiquetas al español
   - Ajusta colores y claridad si es necesario

3. **Usar recursos educativos:**
   - OpenStax Anatomy & Physiology (licencia libre)
   - Recursos Creative Commons
   - Asegúrate de tener derecho a usar la imagen

**Características del diagrama ideal:**
- Fondo claro (blanco o gris muy claro)
- Líneas y flechas oscuras y claras
- Texto grande (mínimo 14pt en la imagen final)
- Código de colores consistente
- Etiquetas en español médico correcto

#### Paso 2: Subir a Firebase Storage

1. Ir a Firebase Console → Storage
2. Navegar a la carpeta `diagramas/` (créala si no existe)
3. Subir tu imagen
4. Click en la imagen subida
5. Copiar el "Download URL" completo

#### Paso 3: Crear Documento en Firestore

1. Ir a Firebase Console → Firestore Database
2. Abrir la colección `diagramas`
3. Click en "Add document"
4. Dejar que Firestore genere el ID automáticamente
5. Agregar los campos:

**Ejemplo para una vía:**
```json
{
  "nombre": "Tracto Óptico",
  "type": "via",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/diagramas%2Ftracto_optico.png?alt=media&token=..."
}
```

**Ejemplo para una estructura:**
```json
{
  "nombre": "Ganglios Basales",
  "type": "estructura",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/neuroanotomy.appspot.com/o/diagramas%2Fganglios_basales.png?alt=media&token=..."
}
```

#### Paso 4: Verificar en la App

1. Abre la aplicación
2. Navega a la sección de diagramas
3. Verifica que tu nuevo diagrama aparezca
4. Verifica que la imagen se vea clara
5. Prueba hacer zoom para confirmar legibilidad

---

## Colección: users

### Descripción

La colección `users` almacena todos los datos específicos de cada usuario de la aplicación. Cada documento representa una cuenta de usuario identificada por su Firebase Authentication UID.

**Funcionalidad en la app:**
- Cuando un usuario se registra, se crea automáticamente un documento en esta colección
- Almacena notas personales de estudio
- Guarda resultados de quizzes generados por IA
- Rastrea progreso y actividades de aprendizaje
- Todos los datos son privados para cada usuario

**Privacidad:**
- Solo el usuario autenticado puede leer/escribir sus propios datos
- Las reglas de seguridad de Firestore impiden que usuarios vean datos de otros
- Los administradores pueden acceder para soporte, pero los datos son sensibles

---

### Estructura del Documento User

**Ruta:** `users/{userId}`

El `userId` es el UID generado por Firebase Authentication cuando el usuario crea su cuenta.

El documento principal del usuario puede contener campos de perfil como:
- Email (si se desea almacenar)
- Nombre de usuario
- Fecha de registro
- Preferencias de estudio
- Estadísticas generales

La mayoría de los datos están en subcolecciones anidadas.

---

### Subcolección: structures

**Ruta:** `users/{userId}/structures/{structureId}`

Esta subcolección almacena datos relacionados con estructuras anatómicas específicas que el usuario ha estudiado.

**Cómo funciona en la app:**

1. **Creación automática:**
   - Cuando un usuario toca un segmento por primera vez (ej: "corteza_motora")
   - La app crea un documento en `structures` con `structureId == "corteza_motora"`

2. **Propósito:**
   - Agrupa todas las notas y actividades relacionadas con esa estructura
   - Permite rastrear cuántas veces ha estudiado esa región
   - Facilita mostrar historial de estudio por estructura

**Ejemplo de estructura de documento:**
```json
{
  "structureId": "corteza_motora",
  "structureName": "Corteza Motora Primaria",
  "firstStudied": "2024-01-15T10:30:00Z",
  "lastAccessed": "2024-01-20T14:45:00Z",
  "timesAccessed": 5
}
```

---

### Subcolección: notes

**Ruta:** `users/{userId}/structures/{structureId}/notes/{noteId}`

Esta subcolección contiene las notas de estudio que el usuario crea para cada estructura anatómica.

**Cómo funciona en la app:**

1. **Interfaz de notas:**
   - Cuando el usuario toca una estructura, aparece un botón "Agregar Nota"
   - Puede escribir texto libre, observaciones, mnemotecnias, etc.
   - Al guardar, se crea un documento en esta subcolección

2. **Visualización:**
   - Las notas se muestran cuando el usuario vuelve a ver esa estructura
   - Puede editar o eliminar notas anteriores
   - Las notas tienen timestamp para mostrar cuándo fueron creadas

**Estructura de documento Note:**
```json
{
  "content": "La corteza motora primaria controla movimientos voluntarios. Homúnculo motor representa partes del cuerpo. Recordar: manos y cara tienen representación grande.",
  "createdAt": "2024-01-15T10:35:00Z",
  "updatedAt": "2024-01-15T10:35:00Z",
  "tags": ["movimiento", "homúnculo"]
}
```

**Campos típicos:**
- `content`: El texto de la nota del usuario
- `createdAt`: Timestamp de creación
- `updatedAt`: Timestamp de última edición
- `tags`: Array de etiquetas para organización (opcional)
- `isFavorite`: Booleano si el usuario marcó como favorita (opcional)

---

### Subcolección: activities

**Ruta:** `users/{userId}/structures/{structureId}/notes/{noteId}/activities/{activityId}`

Esta subcolección registra actividades de estudio relacionadas con notas específicas, principalmente resultados de quizzes generados por IA.

**Cómo funciona en la app:**

1. **Generación de quiz:**
   - El usuario tiene una nota sobre "corteza_motora"
   - Presiona el botón "Generar Quiz"
   - La app envía el contenido de la nota a ChatGPT
   - ChatGPT genera preguntas de opción múltiple

2. **Registro de actividad:**
   - El usuario responde el quiz
   - Al terminar, se crea un documento en `activities`
   - Se guarda: preguntas, respuestas del usuario, score, tiempo

3. **Análisis de progreso:**
   - La app puede mostrar gráficas de mejora
   - Identificar conceptos que necesitan más estudio
   - Implementar repetición espaciada

**Estructura de documento Activity:**
```json
{
  "type": "quiz",
  "score": 4,
  "totalQuestions": 5,
  "percentage": 80,
  "completedAt": "2024-01-15T11:00:00Z",
  "timeSpent": 180,
  "questions": [
    {
      "question": "¿Qué tipo de movimientos controla la corteza motora primaria?",
      "options": ["Voluntarios", "Reflejos", "Autonómicos", "Inconscientes"],
      "correctAnswer": 0,
      "userAnswer": 0,
      "isCorrect": true
    }
  ]
}
```

**Campos típicos:**
- `type`: Tipo de actividad (`"quiz"`, `"review"`, `"flashcard"`)
- `score`: Número de respuestas correctas
- `totalQuestions`: Total de preguntas
- `percentage`: Porcentaje de acierto
- `completedAt`: Timestamp de finalización
- `timeSpent`: Segundos que tomó completar
- `questions`: Array con las preguntas y respuestas

---

### Flujo Completo de Datos de Usuario

**Ejemplo de flujo cuando un usuario estudia:**

1. **Usuario abre corte "hemisferio_derecho"**
   - App carga el documento desde `cortes` donde `id == "hemisferio_derecho"`

2. **Usuario toca el segmento "corteza_motora"**
   - App detecta el toque en el área definida por el path SVG
   - Muestra nombre: "Corteza Motora Primaria"
   - Busca/crea documento: `users/{userId}/structures/corteza_motora`

3. **Usuario crea una nota**
   - Escribe: "Controla movimientos voluntarios..."
   - App guarda en: `users/{userId}/structures/corteza_motora/notes/{autoId}`

4. **Usuario genera quiz**
   - App envía nota a ChatGPT API
   - ChatGPT genera 5 preguntas
   - Usuario responde quiz

5. **Usuario completa quiz**
   - App calcula score: 4/5 (80%)
   - Guarda en: `users/{userId}/structures/corteza_motora/notes/{noteId}/activities/{autoId}`

6. **Usuario revisa progreso**
   - App consulta todas las activities del usuario
   - Muestra gráfica de scores por estructura
   - Identifica estructuras que necesitan más estudio

---

### Agregando Datos de Usuario

**Importante:** Los datos de usuario normalmente se crean automáticamente por la aplicación, NO manualmente.

Sin embargo, para propósitos de testing o demostración:

1. **Crear usuario en Authentication:**
   - Firebase Console → Authentication
   - Agregar usuario manualmente o registrarse en la app
   - Copiar el UID del usuario

2. **Crear documento inicial:**
   ```json
   // users/{uid}
   {
     "email": "estudiante@ejemplo.com",
     "registeredAt": "2024-01-15T09:00:00Z",
     "displayName": "Estudiante Ejemplo"
   }
   ```

3. **No es necesario crear structures/notes/activities manualmente:**
   - La app los crea automáticamente al usar las funciones
   - Crear manualmente puede causar inconsistencias

---

## Interconexiones y Relaciones de Datos

### Navegación entre Cortes

**Tipo de relación:** Referencia por valor de campo

**Cómo funciona:**
- El campo `derechaId` en el corte A contiene el valor del campo `id` del corte B
- No es una referencia directa de Firestore (Firestore Reference type)
- La app hace una query: `WHERE id == derechaId`

**Ejemplo:**
```
Corte A (frontal):
  derechaId: "hemisferio_izquierdo"

Corte B (hemisferio_izquierdo):
  id: "hemisferio_izquierdo"

Query: cortes.where("id", "==", "hemisferio_izquierdo")
```

**Ventajas:**
- Flexible, fácil de cambiar
- Valores legibles por humanos
- No depende de Document IDs autogenerados

**Importante al agregar cortes:**
- El valor de `id` debe ser único en toda la colección
- Los valores de navegación deben coincidir exactamente con un `id` existente
- Si el `id` de destino no existe, la navegación fallará

---

### Segmentos vinculados a Cortes

**Tipo de relación:** Subcolección

**Cómo funciona:**
- Los segmentos son hijos directos de un corte específico
- El path completo incluye el corte padre: `cortes/{corteId}/segmentos/{segmentoId}`
- No pueden existir independientemente

**Coordinación de datos:**
- Los paths SVG están calibrados para la imagen del corte padre
- Si cambias la imagen del corte, debes recalibrar todos los paths de segmentos
- Un segmento no puede compartirse entre múltiples cortes

---

### Usuarios vinculados a Estructuras Anatómicas

**Tipo de relación:** Referencia implícita por ID

**Cómo funciona:**
- El `structureId` en `users/{uid}/structures/{structureId}` debería coincidir con el `id` de un segmento
- No es una referencia forzada por Firestore
- La app asume que `structureId == segmento.id`

**Ejemplo de flujo:**
```
Usuario toca segmento:
  segmento.id = "corteza_motora"

App crea/busca:
  users/{uid}/structures/corteza_motora

Relación implícita:
  structureId "corteza_motora" → segmento.id "corteza_motora"
```

**Importante:**
- Si eliminas un segmento, los datos de usuario persisten (no se borran automáticamente)
- Si renombras el `id` de un segmento, las notas de usuario quedan huérfanas
- Mantén consistencia en los IDs de estructuras

---

## Firebase Storage: Organización de Imágenes

Las imágenes referenciadas en la base de datos se almacenan en Firebase Storage con la siguiente estructura:

```
/cortes/
  hemisferio_derecho.png
  hemisferio_derecho_acuarela.png
  frontal.png
  frontal_acuarela.png
  medial_izquierdo.png
  ventral.png
  ...

/diagramas/
  corticoespinal.png
  espinotalamico_lateral.png
  talamo.png
  amigdala.png
  ...
```

### Subiendo Imágenes a Storage

**Paso 1: Acceder a Storage**
1. Firebase Console
2. Navegar a sección "Storage"
3. Si es la primera vez, hacer click en "Get Started"

**Paso 2: Crear Carpetas**
1. Click en "Create folder"
2. Crear carpeta `cortes`
3. Crear carpeta `diagramas`

**Paso 3: Subir Archivos**
1. Entrar a la carpeta correspondiente
2. Click en "Upload file"
3. Seleccionar tu imagen
4. Esperar a que termine la subida

**Paso 4: Obtener URL**
1. Click en el archivo subido
2. En el panel derecho, copiar "Download URL" completo
3. Esa URL va en los campos `imageUrl`, `realImage`, o `aquarelaImage`

### Requisitos de Imágenes

**Para Cortes:**
- **Formato:** PNG (preferido) o JPG
- **Resolución mínima:** 1000px en el lado más largo
- **Resolución recomendada:** 1500-2000px
- **Tamaño de archivo:** Menor a 2MB para rendimiento
- **Calidad:** Alta definición, anatomía clara

**Para Diagramas:**
- **Formato:** PNG (preferido para gráficos)
- **Resolución mínima:** 1200px
- **Etiquetado:** Texto grande y legible
- **Fondo:** Claro para ahorrar espacio
- **Tamaño de archivo:** Menor a 1MB ideal

**Nombres de archivo:**
- Usar snake_case: `hemisferio_derecho.png`
- Descriptivos y en español
- Sin espacios ni caracteres especiales
- Consistentes con el campo `id` del documento

---

## Reglas de Seguridad de Firestore

Para proteger los datos de usuarios y controlar el acceso al contenido, se deben configurar las reglas de seguridad:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Colección cortes: Lectura pública, escritura solo admin
    match /cortes/{corte} {
      allow read: if true;  // Cualquiera puede leer
      allow write: if request.auth != null &&
                      request.auth.token.admin == true;  // Solo admins pueden escribir

      // Subcolección segmentos
      match /segmentos/{segmento} {
        allow read: if true;
        allow write: if request.auth != null &&
                        request.auth.token.admin == true;
      }

      // Subcolección vistas
      match /vistas/{vista} {
        allow read: if true;
        allow write: if request.auth != null &&
                        request.auth.token.admin == true;
      }
    }

    // Colección diagramas: Lectura pública, escritura solo admin
    match /diagramas/{diagrama} {
      allow read: if true;
      allow write: if request.auth != null &&
                      request.auth.token.admin == true;
    }

    // Colección users: Privada para cada usuario
    match /users/{userId} {
      // Solo el usuario dueño puede leer/escribir sus datos
      allow read, write: if request.auth != null &&
                            request.auth.uid == userId;

      // Todas las subcolecciones heredan la misma regla
      match /{document=**} {
        allow read, write: if request.auth != null &&
                              request.auth.uid == userId;
      }
    }
  }
}
```

### Explicación de las Reglas

**Contenido Anatómico (cortes y diagramas):**
- Cualquier persona puede leer (incluso sin autenticarse)
- Solo administradores pueden agregar/modificar/eliminar
- Esto permite que el contenido educativo sea abierto
- Protege contra modificaciones no autorizadas

**Datos de Usuario:**
- Solo accesibles por el usuario autenticado que los creó
- Nadie más puede ver notas o scores de otros usuarios
- Protege la privacidad del estudiante

**Implementar rol de admin:**
Para marcar usuarios como administradores, usar Firebase Authentication Custom Claims en Cloud Functions:

```javascript
admin.auth().setCustomUserClaims(uid, { admin: true });
```

---

## Mejores Prácticas

### Al Agregar Contenido

**Antes de crear documentos nuevos:**
- Verifica que no exista contenido similar
- Revisa la nomenclatura existente para mantener consistencia
- Prepara todas las imágenes antes de crear documentos
- Prueba las URLs de imágenes en un navegador

**Nombres e IDs:**
- **IDs (campo id):** snake_case, español o latín, descriptivo
  - Correcto: `"corteza_motora"`, `"nucleo_caudado"`
  - Incorrecto: `"CortezaMotora"`, `"cm1"`, `"corteza motora"`

- **Nombres (campo nombre):** Capitalización correcta, español médico
  - Correcto: `"Corteza Motora Primaria"`, `"Núcleo Caudado"`
  - Incorrecto: `"CORTEZA MOTORA"`, `"corteza motora primaria"`

**Integridad de datos:**
- Los IDs de navegación deben apuntar a cortes que existen
- Las URLs de imágenes deben ser accesibles
- Los paths SVG deben formar regiones cerradas
- Los valores de `type` en diagramas deben ser exactamente `"via"` o `"estructura"`

---

### Versionamiento y Cambios

**Si necesitas cambiar el `id` de un corte:**

1. El cambio romperá las navegaciones que apunten a ese ID
2. Busca todos los cortes que tengan `*Id` apuntando al ID antiguo
3. Actualiza esos valores antes de cambiar el ID principal
4. Las notas de usuarios quedarán huérfanas si hay `structureId` que coincidan

**Si cambias la imagen de un corte:**

1. Todos los paths de segmentos necesitarán recalibrarse
2. Considera crear un nuevo corte en lugar de reemplazar
3. Si reemplazas, mantén exactamente las mismas dimensiones

**Si eliminas un corte:**

1. Busca referencias de navegación que apunten a él
2. Elimina o actualiza esos campos de navegación
3. Considera marcar como "inactivo" en lugar de eliminar

---

### Testing y Verificación

**Después de agregar un corte:**

1. Abre la app y verifica que el corte aparezca en la lista
2. Verifica que la imagen cargue correctamente
3. Prueba todos los botones de navegación
4. Verifica que los segmentos respondan al toque
5. Prueba alternar entre vista realista y acuarela (si aplica)

**Después de agregar segmentos:**

1. Toca cada región y verifica que se resalte correctamente
2. Verifica que el nombre aparezca correcto
3. Prueba crear una nota sobre esa estructura
4. Verifica que el área de toque sea intuitiva (no demasiado pequeña)

**Después de agregar un diagrama:**

1. Verifica que aparezca en la lista de diagramas
2. Verifica que esté en la categoría correcta (vías o estructuras)
3. Prueba hacer zoom para verificar legibilidad
4. Confirma que las etiquetas sean claras

---

## Solución de Problemas

### La navegación no funciona

**Síntoma:** Al presionar un botón de navegación, no pasa nada o aparece error

**Causas posibles:**
1. El valor del campo de navegación no coincide con ningún `id` existente
2. Hay un error tipográfico en el valor
3. El corte de destino existe pero su campo `id` es diferente

**Solución:**
- Verifica que `corte.derechaId == corteDestino.id` exactamente
- Los espacios importan: `"frontal "` ≠ `"frontal"`
- Mayúsculas importan: `"Frontal"` ≠ `"frontal"`

---

### Los segmentos no aparecen o están mal posicionados

**Síntoma:** Las regiones interactivas no se ven o están en el lugar equivocado

**Causas posibles:**
1. Las coordenadas del path están calibradas para una imagen diferente
2. La imagen fue redimensionada después de crear los paths
3. El path no está bien formado (faltan comandos, no cierra)

**Solución:**
- Verifica que la imagen actual tenga las mismas dimensiones que cuando creaste los paths
- Abre el SVG path en un editor y verifica que tenga sentido
- Usa un validador SVG para verificar sintaxis
- Recrea los paths con la imagen correcta

---

### Las imágenes no cargan

**Síntoma:** Se ve un placeholder o error en lugar de la imagen

**Causas posibles:**
1. La URL de Storage no es pública o está mal formada
2. Falta el token de acceso (`?alt=media&token=...`)
3. El archivo fue eliminado de Storage
4. Problemas de red o permisos

**Solución:**
- Copia la URL y pégala en un navegador para verificar que cargue
- Asegúrate de que la URL incluya `?alt=media&token=...`
- Verifica en Firebase Storage que el archivo exista
- Revisa las reglas de Storage para asegurar acceso público de lectura

---

### No puedo agregar nuevos documentos

**Síntoma:** Error de permisos al intentar crear contenido

**Causas posibles:**
1. Las reglas de seguridad requieren autenticación admin
2. No estás autenticado
3. Tu cuenta no tiene el claim de admin

**Solución:**
- Si eres admin, usa Cloud Functions para establecer custom claim
- Temporalmente puedes modificar las reglas para permitir escritura durante desarrollo
- **Importante:** No dejes las reglas abiertas en producción

---

### Los datos de usuario no persisten

**Síntoma:** Las notas o scores desaparecen

**Causas posibles:**
1. El usuario no está autenticado correctamente
2. Problemas de sincronización offline
3. Reglas de seguridad rechazan la escritura

**Solución:**
- Verifica que `Firebase.Auth().currentUser` exista
- Revisa logs de Firestore para errores de permisos
- Habilita persistencia offline en la configuración de Firestore

---

## Exportando Datos

Para backup o análisis, puedes exportar la estructura completa de la base de datos:

### Usando el Script de Exportación

```bash
flutter run scripts/export_firestore.dart -d <device-id>
```

Este script se conecta a Firestore y exporta:
- Todos los cortes con sus segmentos y vistas
- Todos los diagramas
- Estructura de ejemplo de usuarios (sin datos privados)

El output se imprime en formato JSON en la consola y puede redirigirse a un archivo.

### Exportación Manual

**Firebase Console:**
1. Ir a Firestore Database
2. Click en una colección
3. Menú tres puntos → "Export collection"
4. Sigue las instrucciones para exportar a Cloud Storage

**Importante:**
- Los exports incluyen subcollecciones
- Los exports son en formato JSON
- Útil para backups antes de cambios grandes

---

## Soporte y Recursos

**Documentación relacionada:**
- README.md - Guía de instalación y configuración de la app
- Firebase Firestore Docs: https://firebase.google.com/docs/firestore
- SVG Path Tutorial: https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths

**Para preguntas sobre:**
- **Estructura de datos:** Consultar este documento
- **Instalación de la app:** Consultar README.md
- **Problemas técnicos de Firebase:** Documentación oficial de Firebase
- **SVG y paths:** Tutoriales de MDN Web Docs

---

## Expansión Futura

La estructura actual permite varias mejoras futuras:

**Segmentos Mejorados:**
- Agregar campo `description` con información detallada de cada estructura
- Agregar campo `clinicalCorrelation` con relevancia clínica
- Vincular estructuras relacionadas entre diferentes cortes
- Agregar campo `level` (básico, intermedio, avanzado)

**Diagramas Interactivos:**
- Implementar subcolección `hotspots` similar a segmentos
- Permitir tocar partes del diagrama para ver información
- Agregar animaciones de vías neurales
- Incluir videos cortos de procesos fisiológicos

**Sistema de Aprendizaje:**
- Implementar algoritmo de repetición espaciada
- Agregar niveles de maestría por estructura
- Crear rutas de aprendizaje recomendadas
- Badges y logros por progreso

**Navegación 3D:**
- Agregar transiciones animadas entre cortes
- Implementar vista de "cubo 3D" para orientación
- Incluir rotación suave entre perspectivas
- Agregar zoom levels con la subcolección `vistas`

**Colaboración:**
- Permitir compartir notas entre usuarios (con permisos)
- Crear grupos de estudio
- Foros de discusión por estructura
- Recursos compartidos por la comunidad

---

Esta guía documenta completamente la estructura de la base de datos al momento de su creación. A medida que la aplicación evolucione, asegúrate de mantener este documento actualizado para reflejar los cambios en la estructura de datos.
