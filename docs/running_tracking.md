# Running Tracking V1

La primera version de Running usa `geolocator` para tracking en primer plano. La integracion queda encapsulada en `lib/services/running_tracking_service.dart` para poder reemplazar esa fuente de posiciones sin tocar pantallas ni Provider.

## Preparado Para Background Tracking

Si el producto necesita tracking confiable con la app bloqueada o en segundo plano, la extension natural es crear otra implementacion de servicio con la misma responsabilidad que `RunningTrackingService` y conectar su stream al `RunningProvider`.

Opciones futuras:
- Plugin nativo/background open source si alcanza para el caso de uso.
- `flutter_background_geolocation` si se acepta dependencia premium y costo operativo.

No se agrega dependencia premium en V1 para mantener compilacion simple y evitar vendor lock-in temprano.

## Calidad GPS

Los puntos se filtran en `RunningGpsFilter` antes de afectar metricas:
- Rechazo por precision peor a la configurada.
- Rechazo de timestamps ausentes, futuros o no monotónicos.
- Rechazo de saltos que impliquen velocidad superior a una velocidad humana razonable.
- Suavizado Kalman 1D separado para latitud y longitud.

## Metas De Running

Cada corrida puede iniciarse con una meta desde la pantalla activa:
- Distancia: se ingresa en kilometros y se persiste internamente en metros.
- Tiempo: se ingresa en minutos y se evalua contra `movingSeconds`, es decir, tiempo real en movimiento sin pausas manuales ni auto-pausa.
- Frecuencia semanal: se ingresa como cantidad de sesiones objetivo de lunes a domingo.

La meta queda serializada dentro de `RunningSession.goal` y el resultado final en `RunningSession.goalReached`.

El progreso en vivo se calcula en `RunningProvider` para distancia/tiempo con las metricas actuales. Para frecuencia semanal se muestra el total de sesiones ya guardadas en la semana mas la corrida activa.

Al finalizar una sesion, `RunningHistoryProvider.add()` recalcula la meta semanal despues de insertar conceptualmente la sesion actual. Esto evita decidir la frecuencia antes de que la actividad forme parte del historial persistido.

El dashboard agrega estadisticas acumuladas, racha de dias con corrida, sesiones completadas, estado de la ultima meta semanal y un calendario mensual sin dependencia externa que resalta los dias con actividad.
