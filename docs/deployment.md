# Despliegue Firestore

Esta guia describe como aplicar configuracion de Firestore para KDSkull sin tocar datos de negocio manualmente.

## Archivos implicados

- `firebase.json`
- `database/firestore.rules`
- `database/firestore.indexes.json`

## Requisitos

- Firebase CLI instalado.
- Sesion iniciada en Firebase.
- Permisos sobre el proyecto `kds-tfg`.

## Pasos de despliegue

1. Iniciar sesion:

```bash
firebase login
```

2. Seleccionar proyecto:

```bash
firebase use kds-tfg
```

3. Desplegar reglas e indices:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## Verificaciones recomendadas

- Revisar en consola Firebase que las reglas activas son las esperadas.
- Confirmar que las consultas de cocina/sala no piden indices nuevos.
- Validar alta/edicion de platos y estaciones desde `apps/admin`.

## Incidencias comunes

### Firebase pide un indice nuevo

1. Copiar la definicion sugerida por Firebase.
2. Añadirla en `database/firestore.indexes.json`.
3. Volver a ejecutar:

```bash
firebase deploy --only firestore:indexes
```

### Error de permisos al desplegar

- Verifica que tu cuenta tiene permisos de editor/owner en `kds-tfg`.
- Repite `firebase login` y `firebase use kds-tfg`.

## Notas operativas

- Los datos de negocio (platos, estaciones, etc.) se gestionan desde la app de administracion.
- Mantener reglas e indices versionados evita diferencias entre entornos.
