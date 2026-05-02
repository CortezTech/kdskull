# KDS Sala

Aplicacion de sala para toma y gestion de pedidos.

## Funcionalidad

- Seleccion de mesas.
- Gestion de carrito y envio de pedidos.
- Consulta del estado de pedidos y progreso por mesa.

## Requisitos

- Flutter instalado y configurado.
- Proyecto Firebase `kds-tfg` accesible.
- Archivo de configuracion Firebase generado en `lib/firebase_options.dart`.

## Ejecutar en desarrollo

Desde la raiz del repositorio:

```bash
flutter run -d chrome -t apps/sala/lib/main.dart
```

O entrando en esta app:

```bash
cd apps/sala
flutter run
```

## Firebase

- Configuracion FlutterFire de esta app: `apps/sala/firebase.json`
- Opciones de Firebase en codigo: `apps/sala/lib/firebase_options.dart`
- Reglas e indices Firestore del proyecto (compartidos): `database/`
