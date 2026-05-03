# Database Seed (Firestore)

Script de inicializacion de datos para Firestore orientado a la coleccion de platos.

## Archivos

- `firestore.rules`: reglas de seguridad.
- `firestore.indexes.json`: indices de Firestore.
- `seed_firestore.js`: script para insertar platos de ejemplo.
- `package.json`: dependencias y comando del seed.

## Estructura de datos sembrada

Cada documento en la coleccion `dishes` contiene:

- `available` (boolean)
- `category` (string)
- `name` (string)
- `stationId` (string)
- `stdPrepTimeSec` (number)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

## Requisitos

- Node.js 18+.
- Credenciales de Firebase Admin:
  - Opcion recomendada: variable de entorno `GOOGLE_APPLICATION_CREDENTIALS`.
  - Opcion alternativa: usar `serviceAccountKey.json` y descomentar el bloque en `seed_firestore.js`.

## Comandos

Desde `database/`:

```bash
npm install
npm run seed
```
