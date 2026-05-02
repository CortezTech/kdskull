# KDS Cocina

Aplicacion de cocina para visualizar y gestionar comandas por estacion.

## Funcionalidad

- Visualizacion de pedidos en curso.
- Organizacion por estaciones de cocina.
- Actualizacion del estado de elaboracion de platos.

## Requisitos

- Flutter instalado y configurado.
- Proyecto Firebase `kds-tfg` accesible.
- Archivo de configuracion Firebase generado en `lib/firebase_options.dart`.

## Ejecutar en desarrollo

Desde la raiz del repositorio:

```bash
flutter run -d chrome -t apps/cocina/lib/main.dart
```

O entrando en esta app:

```bash
cd apps/cocina
flutter run
```

## Firebase

- Configuracion FlutterFire de esta app: `apps/cocina/firebase.json`
- Opciones de Firebase en codigo: `apps/cocina/lib/firebase_options.dart`
- Reglas e indices Firestore del proyecto (compartidos): `database/`
