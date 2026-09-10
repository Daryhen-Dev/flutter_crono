# Tip Tap Workout

Aplicación Flutter para entrenamientos por intervalos y registro de corridas con GPS. Combina temporizadores configurables, audio por fase, rutinas guardadas, historial local y una experiencia de Running V1 para registrar distancia, ritmo y rutas mientras la aplicación permanece en primer plano.

> El paquete y los identificadores de plataforma conservan el nombre `flutter_crono`; el nombre visible dentro de la aplicación es **Tip Tap Workout**.

## Índice

- [Características](#características)
- [Requisitos e inicio rápido](#requisitos-e-inicio-rápido)
- [Uso](#uso)
- [Running con GPS](#running-con-gps)
- [Datos, privacidad y conectividad](#datos-privacidad-y-conectividad)
- [Arquitectura](#arquitectura)
- [Rutas](#rutas)
- [Stack técnico](#stack-técnico)
- [Pruebas y análisis](#pruebas-y-análisis)
- [Plataformas y compilación](#plataformas-y-compilación)
- [Documentación adicional](#documentación-adicional)

## Características

### Temporizadores de entrenamiento

| Modo | Descripción |
|---|---|
| **Clásico** | Preparación, trabajo, descanso y cantidad de rondas configurables. |
| **Tabata** | Intervalos HIIT con preparación, rondas por tabata, varios tabatas y descanso largo entre ellos. |
| **Personalizado** | Constructor de secuencias que combina bloques Clásico y Tabata con valores independientes y descanso global entre bloques. |

Los tres modos incluyen control de pausa, reanudación y detención. Al terminar, se registra un resumen local del entrenamiento.

### Audio y experiencia visual

- Música de trabajo y descanso seleccionable de los assets incluidos en `assets/audio/work/` y `assets/audio/rest/`.
- Reproducción en bucle por fase, con pausa y reanudación junto al temporizador.
- Pitidos de cuenta regresiva generados en memoria; durante el pitido la música reduce su volumen temporalmente y luego se restaura.
- Vista previa de la música configurada desde la pantalla de audio.
- Tres skins para el temporizador activo: **Classic**, **Cyber Grid** y **Terminal**.
- La carpeta `assets/audio/tones/` está preparada para tonos de inicio o final de fase, pero esos tonos personalizados aún no forman parte de la funcionalidad implementada.

### Rutinas e historial

- Guardado local de configuraciones como rutinas reutilizables.
- Inicio directo de una rutina guardada.
- Historial de entrenamientos por intervalos con tipo, rondas o bloques, duración y fecha.
- Filtros de historial por período y tipo de temporizador.
- Resumen de sesiones, tiempo total y promedio de duración.

## Requisitos e inicio rápido

El proyecto requiere un SDK de Flutter compatible con la restricción de Dart declarada en [`pubspec.yaml`](pubspec.yaml): `^3.9.2`. La versión exacta de Flutter no está fijada en el repositorio.

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Ejecutar en un dispositivo, emulador o destino disponible
flutter run
```

Para comprobar la instalación local:

```bash
flutter --version
flutter doctor
```

## Uso

### Crear un entrenamiento por intervalos

1. Desde la pantalla principal, elegir **Clásico**, **Tabata** o **Personalizado**.
2. Configurar los tiempos y las rondas o bloques requeridos.
3. Opcionalmente, guardar la configuración como rutina.
4. Iniciar el temporizador y utilizar los controles de pausa, reanudación o detención.
5. Consultar el resultado en el historial al finalizar.

### Configurar audio y skin

- Abrir la configuración de audio para seleccionar música de trabajo y descanso.
- Elegir una skin desde la pantalla principal antes de iniciar el temporizador.
- El estado de audio y la skin seleccionada se guardan localmente.

## Running con GPS

Running es una primera versión de registro de corridas **en primer plano**. Está pensada para acompañar una sesión mientras la aplicación permanece abierta y activa; no implementa tracking confiable con la aplicación bloqueada ni en segundo plano.

### Flujo de una corrida

1. Abrir **Running** desde la pantalla principal.
2. Elegir una meta antes de iniciar:
   - **Distancia:** ingresada en kilómetros y guardada internamente en metros.
   - **Tiempo:** ingresado en minutos y evaluado con el tiempo efectivo en movimiento.
   - **Frecuencia semanal:** cantidad de sesiones objetivo entre lunes y domingo.
3. Conceder el permiso de ubicación y verificar que los servicios de ubicación del dispositivo estén activos.
4. Iniciar la corrida. La pantalla activa muestra ruta, distancia, tiempo en movimiento, ritmo actual, ritmo medio y el progreso de la meta.
5. Pausar o reanudar manualmente cuando sea necesario. La aplicación también puede entrar y salir de auto-pausa según la velocidad recibida.
6. Finalizar la sesión para guardar el resumen, la meta y la ruta localmente.

### Métricas y calidad de GPS

Antes de incorporarse a la ruta, cada posición pasa por un filtro que descarta datos no confiables:

- precisión inválida o peor que la permitida por la configuración;
- timestamps futuros o no monotónicos;
- saltos que impliquen una velocidad humana implausible;
- suavizado Kalman independiente para latitud y longitud.

La configuración inicial usa una precisión máxima de 25 m, velocidad humana máxima de 8.5 m/s, auto-pausa desde 0.7 m/s tras 8 segundos y una ventana de 200 m para el ritmo. Estos valores son criterios de filtrado y cálculo; no son una garantía de precisión GPS.

### Resultados e historial de Running

Cada sesión finalizada conserva localmente:

- fecha de inicio y finalización;
- duración total y tiempo efectivo en movimiento;
- distancia, velocidad promedio y ritmo promedio;
- puntos GPS aceptados y eventos de pausa;
- meta elegida y su resultado.

El dashboard de Running muestra distancia total, tiempo en movimiento, cantidad de sesiones, racha de días, estado de la última meta semanal y un calendario mensual con actividad. El historial permite revisar cada resumen y abrir el detalle de la ruta.

### Permisos y limitaciones

- **Android:** declara permisos de ubicación precisa y aproximada, además de acceso a Internet para los mapas.
- **iOS:** declara `NSLocationWhenInUseUsageDescription` para explicar el uso de ubicación durante una corrida.
- El permiso se solicita en tiempo de ejecución. Si se rechaza o el servicio de ubicación está desactivado, no se puede comenzar el registro.
- No se declaró acceso de ubicación en segundo plano; cerrar, bloquear o suspender la aplicación puede interrumpir el seguimiento.
- El mapa usa `flutter_map` con teselas de OpenStreetMap. Se necesita conectividad para cargar las teselas, aunque los puntos ya registrados permanecen guardados localmente.

## Datos, privacidad y conectividad

La aplicación persiste datos en el dispositivo mediante `SharedPreferences`. En el código actual no se encontró una ruta de sincronización ni un backend para subir información.

| Dato | Uso local |
|---|---|
| Rutinas y configuraciones de intervalos | Reutilizar entrenamientos y restaurar preferencias. |
| Historial de temporizadores | Mostrar resultados y estadísticas. |
| Ajustes de audio y skin | Mantener la experiencia elegida entre aperturas. |
| Ajustes, sesiones, rutas y pausas de Running | Calcular métricas, metas, historial y detalles de recorrido. |

Las rutas de Running contienen coordenadas de ubicación. Antes de distribuir la aplicación, revisar la política de privacidad, el modelo de almacenamiento y los requisitos de uso y atribución del proveedor de teselas elegido.

## Arquitectura

La aplicación usa una arquitectura por responsabilidades con `Provider` y `ChangeNotifier` para el estado. `main.dart` inicializa `SharedPreferences`, crea los providers globales y configura la aplicación con `MaterialApp.router`.

```text
lib/
├── main.dart                         # Arranque, almacenamiento, providers y shell visual
├── core/
│   ├── router/app_router.dart        # Rutas declarativas con GoRouter
│   └── theme/                        # Colores y temas de skins
├── models/                           # Configuraciones, estados, registros y metas
├── providers/                        # Estado y lógica de presentación
├── screens/
│   ├── audio/                        # Configuración de música
│   ├── config/                       # Formularios de Clásico, Tabata y Personalizado
│   ├── history/                      # Historial de temporizadores
│   ├── home/                         # Selector principal de funcionalidades
│   ├── presets/                      # Rutinas guardadas
│   ├── running/                      # Dashboard, corrida activa, historial y mapa
│   └── timer/                        # Temporizador activo, skins y controles
└── services/
    ├── audio_service.dart            # Beeps, música, ducking y vista previa
    ├── running_gps_filter.dart       # Validación y suavizado de posiciones GPS
    ├── running_metrics.dart          # Distancia, velocidad y ritmo
    ├── running_tracking_service.dart # Permisos y stream de ubicación
    └── storage_service.dart          # Persistencia local en SharedPreferences
```

### Estado y flujo de datos

| Área | Responsabilidad principal |
|---|---|
| `TimerProvider` | Tick del temporizador, fases, secuencias, audio y registros de intervalos. |
| Config providers | Edición de parámetros Clásico, Tabata y Personalizado. |
| `PresetsProvider` y `HistoryProvider` | Rutinas e historial de temporizadores. |
| `AudioSettingsProvider` y `SkinProvider` | Preferencias de audio y apariencia. |
| `RunningProvider` | Ciclo de vida de una corrida, pausa, posiciones, métricas y metas en vivo. |
| `RunningHistoryProvider` | Persistencia de sesiones, estadísticas, rachas y metas semanales. |
| `RunningSettingsProvider` | Preferencias de precisión, velocidad, auto-pausa y ritmo. |
| `StorageService` | Serialización local de datos de la aplicación. |

`WakelockPlus` se habilita durante el arranque para evitar que la pantalla se suspenda durante usos prolongados. El comportamiento final puede depender de la política de energía del sistema operativo.

## Rutas

| Ruta | Pantalla | Notas |
|---|---|---|
| `/` | Inicio | Selector de temporizador y Running. |
| `/classic/config` | Configuración Clásico | Parámetros de rondas. |
| `/tabata/config` | Configuración Tabata | Parámetros HIIT. |
| `/custom/config` | Configuración Personalizado | Constructor de bloques. |
| `/timer` | Temporizador activo | Requiere un `TimerType` en `state.extra`. |
| `/presets` | Rutinas guardadas | Listado y gestión local. |
| `/history` | Historial de intervalos | Filtros y estadísticas. |
| `/audio-settings` | Ajustes de audio | Música de trabajo y descanso. |
| `/running` | Dashboard de Running | Inicio y estadísticas de corridas. |
| `/running/active` | Corrida activa | GPS, métricas y controles. |
| `/running/summary` | Resumen de corrida | Requiere un `RunningSession` en `state.extra`. |
| `/running/history` | Historial de Running | Sesiones y detalle de metas. |
| `/running/settings` | Ajustes de Running | Umbrales de filtrado y ritmo. |
| `/running/route` | Detalle de ruta | Requiere un `RunningSession` en `state.extra`. |

Las rutas que requieren `state.extra` están diseñadas para navegación interna y no son deep links autónomos sin proporcionar el objeto correspondiente.

## Stack técnico

| Componente | Tecnología |
|---|---|
| Framework | Flutter con Dart `^3.9.2` |
| Estado | `provider` `^6.1.2` + `ChangeNotifier` |
| Navegación | `go_router` `^14.8.1` |
| Persistencia | `shared_preferences` `^2.3.4` |
| Audio | `audioplayers` `^6.1.0` |
| Ubicación | `geolocator` `^13.0.2` |
| Mapas | `flutter_map` `^7.0.2` + `latlong2` `^0.9.1` |
| Vibración | `vibration` `^2.0.0` |
| Identificadores | `uuid` `^4.5.1` |
| Pantalla activa | `wakelock_plus` `^1.5.2` |
| Linting | `flutter_lints` `^5.0.0` |

Las versiones son las restricciones declaradas en `pubspec.yaml`; la resolución concreta queda registrada en `pubspec.lock`.

## Pruebas y análisis

```bash
# Analizar el código con las reglas de flutter_lints
flutter analyze

# Ejecutar toda la suite
flutter test

# Ejecutar pruebas focalizadas de Running
flutter test test/models/running_goal_test.dart
flutter test test/providers/running_history_provider_test.dart
```

La suite actual cubre serialización y comportamiento de modelos de temporizador, metas de Running y estadísticas de historial de Running. No sustituye pruebas en dispositivo para permisos, GPS real, auto-pausa, mapas o comportamiento al bloquear la aplicación.

## Plataformas y compilación

El repositorio incluye proyectos Flutter para Android, iOS, Web, Linux, macOS y Windows. La configuración de permisos de ubicación está presente en Android e iOS. La paridad de funciones —en particular GPS, mapas y audio— debe validarse en cada plataforma de destino antes de distribuir una versión.

Ejemplos de compilación, una vez instaladas las toolchains requeridas por Flutter:

```bash
flutter build apk
flutter build web
flutter build windows
flutter build macos
flutter build linux
# flutter build ios  # ejecutar desde macOS con Xcode configurado
```

No se asume que estas compilaciones hayan sido ejecutadas ni validadas para todos los destinos desde este repositorio.

## Documentación adicional

- [Notas de diseño de Running V1 (español)](docs/running_tracking.md)
- [`pubspec.yaml`](pubspec.yaml): dependencias, assets y restricción de Dart.
- [`analysis_options.yaml`](analysis_options.yaml): reglas de análisis estático.
