# KDSkull

Kitchen Display System orientado a mejorar la comunicacion operativa en restauracion.

## Descripcion

KDSkull es un proyecto de TFG del ciclo superior de Desarrollo de Aplicaciones Multiplataforma (DAM).  
El sistema conecta sala, cocina y administracion para gestionar pedidos en tiempo real.

## Objetivo

Mejorar la comunicacion entre sala y cocina mediante una solucion digital que permita:

- Crear pedidos por mesa.
- Enviar pedidos a cocina en tiempo real.
- Visualizar pedidos por estacion.
- Actualizar estados de preparacion.
- Gestionar platos y estaciones desde administracion.

## Estructura del repositorio

```text
kdskull/
|-- apps/
|   |-- sala/      # App de sala
|   |-- cocina/    # App de cocina
|   `-- admin/     # App de administracion
|-- packages/
|   `-- shared/    # Modelos, repositorios y logica compartida
|-- database/      # Reglas e indices de Firestore
|-- firebase.json  # Config de despliegue Firestore
`-- README.md
```

## Modulos principales

### Sala

- Seleccion de mesa.
- Seleccion de platos.
- Creacion y envio de pedidos.

### Cocina

- Visualizacion de pedidos por estacion.
- Actualizacion de estado de platos.

Estados principales:

```text
Pendiente -> En preparacion -> Listo
```

### Administracion

- Gestion de platos.
- Gestion de estaciones.
- Control de disponibilidad.

## Tecnologias

- Flutter
- Dart
- Firebase
- Cloud Firestore
- Git y GitHub

## Colecciones principales en Firestore

```text
stations
dishes
orders
orderItems
```

## Requisitos previos

- Flutter instalado.
- Proyecto Firebase configurado (`kds-tfg`).
- Git instalado.

Comprobacion rapida:

```bash
flutter doctor
```

## Instalacion

```bash
git clone https://github.com/CortezTech/kdskull.git
cd kdskull
```

Dependencias por app:

```bash
cd apps/sala && flutter pub get
cd ../cocina && flutter pub get
cd ../admin && flutter pub get
```

## Ejecucion

Sala:

```bash
cd apps/sala
flutter run -d chrome
```

Cocina:

```bash
cd apps/cocina
flutter run -d chrome
```

Admin:

```bash
cd apps/admin
flutter run -d chrome
```

## Despliegue Firestore (BBDD)

La configuracion versionada de la base de datos Firestore esta en:

- `firebase.json`
- `database/firestore.rules`
- `database/firestore.indexes.json`

Pasos para aplicarla manualmente:

1. `firebase login`
2. `firebase use kds-tfg`
3. `firebase deploy --only firestore:rules,firestore:indexes`

Notas:

- Los datos de negocio (platos, estaciones, etc.) se crean y gestionan desde la app admin.
- Si Firestore pide nuevos indices en consultas, actualiza `database/firestore.indexes.json` y vuelve a desplegar.

## Autor

Ronny Cortez Cisneros  
TFG DAM - ThePower FP Oficial
