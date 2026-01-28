# NeuroAnatomy App

App interactiva de neuroanatomía con funcionalidad de cuestionarios generados por inteligencia artificial.

## Requisitos

1. **Flutter**: Necesitas tener Flutter instalado en tu computadora
   - Descarga desde: https://flutter.dev/docs/get-started/install
   - Verifica que esté instalado ejecutando en terminal: `flutter --version`

2. **API Key de OpenAI**: Necesitas una clave de API de OpenAI
   - Crea una cuenta en: https://platform.openai.com
   - Ve a la sección de API Keys y crea una nueva clave
   - Guarda esta clave (empieza con `sk-...`)

## Instalación y Configuración

### Paso 1: Configurar la API Key

1. En la carpeta del proyecto, abre el archivo `.env`
2. Pega tu clave de OpenAI después del `=`:
   ```
   OPEN_AI_API_KEY=tu-clave-aqui
   ```
3. Guarda el archivo

### Paso 2: Instalar Dependencias

Abre una terminal en la carpeta del proyecto y ejecuta:

```bash
flutter pub get
```

### Paso 3: Correr la Aplicación

Para correr la app en un dispositivo o emulador:

```bash
flutter run
```

Para correr en un dispositivo específico:

```bash
# Ver dispositivos disponibles
flutter devices

# Correr en un dispositivo específico
flutter run -d <device-id>
```

## Funcionalidades

- **Visualización interactiva** de cortes cerebrales y diagramas de neuroanatomía
- **Generación automática de cuestionarios** usando IA sobre cualquier texto
- **Notas personales** para guardar apuntes de estudio
- **Autenticación** con Firebase para guardar tu progreso

## Documentación de Base de Datos

Si necesitas agregar o modificar el contenido de la app (cortes cerebrales, diagramas, etc.), consulta la documentación detallada:

- **[Guía de Base de Datos Firestore](FIRESTORE_DATABASE_GUIDE.md)** - Guía completa de la estructura de la base de datos, cómo agregar nuevo contenido, relaciones entre datos y mejores prácticas

## Problemas Comunes

### Error: "API Key not found"
- Verifica que el archivo `.env` existe en la raíz del proyecto
- Asegúrate de que la API Key esté correcta en el archivo `.env`
- Ejecuta `flutter clean` y luego `flutter pub get`

### No aparecen dispositivos disponibles
- Para iOS: Abre Xcode y configura un simulador
- Para Android: Abre Android Studio y crea un emulador AVD
- Para web: Ejecuta `flutter run -d chrome`

## Soporte

Si tienes problemas técnicos, revisa la documentación oficial de Flutter: https://docs.flutter.dev
