# KDS Admin

Aplicacion de administracion del sistema KDS.

## Funcionalidad

- Gestion de platos.
- Gestion de estaciones.
- Mantenimiento de datos de negocio en Firestore.

## Requisitos

- Flutter instalado y configurado.
- Proyecto Firebase `kds-tfg` accesible.
- Archivo de configuracion Firebase generado en `lib/firebase_options.dart`.

## Ejecutar en desarrollo

Desde la raiz del repositorio:

```bash
flutter run -d chrome -t apps/admin/lib/main.dart
```

O entrando en esta app:

```bash
cd apps/admin
flutter run
```

## Firebase

- Configuracion FlutterFire de esta app: `apps/admin/firebase.json`
- Opciones de Firebase en codigo: `apps/admin/lib/firebase_options.dart`
- Reglas e indices Firestore del proyecto (compartidos): `database/`
