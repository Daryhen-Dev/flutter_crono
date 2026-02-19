# Crono - Timer de Entrenamiento

Aplicacion de cronometro/timer para entrenamientos construida con Flutter. Soporta multiples modos de temporizador con feedback de audio, historial de entrenamientos y rutinas guardadas.

**Plataformas:** Android, iOS, Web, Linux, macOS, Windows

## Modos de Timer

### Clasico
Timer de rondas con descanso intermedio.
- Preparacion configurable
- Tiempo de trabajo por ronda
- Descanso entre rondas
- Numero de rondas

### Tabata
Intervalos de alta intensidad con multiples tabatas.
- Preparacion configurable
- Trabajo / Descanso por ronda
- Numero de rondas por tabata
- Numero de tabatas
- Descanso largo entre tabatas

### Personalizado (Constructor de Secuencias)
Permite crear secuencias mezclando bloques de tipo Clasico y Tabata. Cada bloque tiene sus propios parametros de trabajo, descanso y rondas. El timer ejecuta los bloques en orden con un descanso global entre ellos.

- Preparacion inicial configurable
- Descanso entre bloques configurable
- Agregar bloques Clasico o Tabata con valores independientes
- Cada bloque: Trabajo, Descanso, Rondas
- Ejecucion secuencial automatica

## Funcionalidades

### Audio Feedback
Pitidos de cuenta regresiva en los ultimos 4 segundos de cada fase:
- 3 pitidos cortos (segundos 3, 2, 1)
- 1 pitido largo al finalizar la fase

Los tonos se generan en memoria como WAV (880Hz, onda seno) sin necesidad de archivos de audio externos.

### Rutinas Guardadas
Guarda cualquier configuracion de timer como una rutina con nombre para reutilizarla despues. Se persisten en almacenamiento local.

### Historial de Entrenamientos
Registro automatico de cada entrenamiento completado con:
- Tipo de timer utilizado
- Rondas/bloques completados
- Duracion total
- Fecha y hora

Filtros por periodo (semana, mes, anio) y por tipo de timer. Resumen con estadisticas de sesiones totales, tiempo total y promedio.

## Arquitectura

```
lib/
├── main.dart                          # Entry point, providers setup
├── core/
│   ├── router/app_router.dart         # GoRouter - navegacion
│   └── theme/
│       ├── app_colors.dart            # Paleta de colores
│       └── app_theme.dart             # Tema dark global
├── models/
│   ├── timer_type.dart                # Enum: tabata, classic, personalizado
│   ├── timer_phase.dart               # Fases: idle, preparation, work, rest, tabataRest, segmentRest, finished
│   ├── timer_state.dart               # Estado inmutable del timer
│   ├── classic_config.dart            # Config del timer clasico
│   ├── tabata_config.dart             # Config del timer tabata
│   ├── custom_config.dart             # CustomSegment + CustomConfig (secuencias)
│   ├── preset.dart                    # Rutinas guardadas
│   └── workout_record.dart            # Registro de entrenamientos
├── providers/
│   ├── timer_provider.dart            # Logica central del timer (tick, fases, secuencias)
│   ├── classic_config_provider.dart   # Estado config clasico
│   ├── tabata_config_provider.dart    # Estado config tabata
│   ├── custom_config_provider.dart    # Estado config personalizado (lista de segmentos)
│   ├── presets_provider.dart          # CRUD de rutinas guardadas
│   └── history_provider.dart          # Historial con filtros y estadisticas
├── screens/
│   ├── home/home_screen.dart          # Seleccion de modo
│   ├── config/
│   │   ├── classic_config_screen.dart
│   │   ├── tabata_config_screen.dart
│   │   ├── custom_config_screen.dart  # Constructor de secuencias
│   │   └── widgets/
│   │       ├── duration_field.dart    # Selector MM:SS con scroll wheels
│   │       └── counter_field.dart     # Selector numerico +/-
│   ├── timer/
│   │   ├── active_timer_screen.dart   # Timer activo con anillo de progreso
│   │   └── widgets/
│   │       ├── timer_ring.dart        # Anillo circular de progreso
│   │       ├── phase_label.dart       # Etiqueta de fase actual
│   │       ├── round_indicator.dart   # Ronda X/Y, Tabata X/Y, Bloque X/Y
│   │       └── control_buttons.dart   # Pausa, reanudar, detener
│   ├── presets/
│   │   ├── presets_screen.dart
│   │   └── widgets/preset_tile.dart
│   └── history/
│       ├── history_screen.dart
│       └── widgets/
│           ├── period_selector.dart   # Semana/Mes/Anio
│           ├── summary_card.dart      # Estadisticas del periodo
│           ├── type_filter_chips.dart  # Filtro por tipo
│           ├── workout_day_group.dart  # Agrupacion por dia
│           └── workout_record_tile.dart
└── services/
    ├── audio_service.dart             # Generacion y reproduccion de beeps WAV
    └── storage_service.dart           # Persistencia con SharedPreferences
```

## Stack Tecnico

| Componente | Tecnologia |
|---|---|
| Framework | Flutter (Dart >=3.9.2) |
| State Management | Provider + setState |
| Navegacion | GoRouter |
| Persistencia | SharedPreferences |
| Audio | audioplayers (WAV generado en memoria) |
| Vibracion | vibration |
| IDs unicos | uuid |
| Linting | flutter_lints |

## Tema Visual

Tema dark con colores por fase:

| Fase | Color | Hex |
|---|---|---|
| Trabajo | Verde | `#00E676` |
| Descanso | Azul | `#42A5F5` |
| Preparacion | Naranja | `#FF9800` |
| Descanso Tabata / Segmento | Purpura | `#AB47BC` |
| Finalizado | Gris azulado | `#78909C` |
| Fondo | Negro | `#0D0D0D` |
| Acento | Verde | `#00E676` |

## Rutas

| Ruta | Pantalla |
|---|---|
| `/` | Home - Seleccion de modo |
| `/classic/config` | Configuracion Clasico |
| `/tabata/config` | Configuracion Tabata |
| `/custom/config` | Constructor de Secuencias |
| `/timer` | Timer activo (recibe TimerType) |
| `/presets` | Rutinas guardadas |
| `/history` | Historial de entrenamientos |

## Comandos

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run

# Ejecutar tests
flutter test

# Analisis de codigo
flutter analyze

# Build por plataforma
flutter build apk        # Android
flutter build ios         # iOS
flutter build web         # Web
flutter build windows     # Windows
flutter build macos       # macOS
flutter build linux       # Linux
```
