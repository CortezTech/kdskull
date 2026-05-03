# KDSkull

**Kitchen Display System orientado a mejorar la comunicación operativa en restauración**

KDSkull es una aplicación desarrollada como Trabajo Final del ciclo superior de **Desarrollo de Aplicaciones Multiplataforma (DAM)**. El proyecto consiste en un sistema KDS (*Kitchen Display System*) orientado a gestionar pedidos en tiempo real entre sala, cocina y administración.

El sistema está pensado para pequeños y medianos establecimientos de restauración que necesitan mejorar la comunicación entre el personal de sala y cocina sin depender de un TPV completo ni de hardware específico.

---

## Objetivo del proyecto

El objetivo principal de KDSkull es mejorar la comunicación operativa entre sala y cocina mediante una solución digital que permita registrar, visualizar y actualizar pedidos en tiempo real.

La aplicación permite:

- Crear pedidos asociados a mesas.
- Añadir platos disponibles a un pedido.
- Enviar pedidos a cocina en tiempo real.
- Visualizar los pedidos organizados por estaciones de trabajo.
- Actualizar el estado de preparación de cada plato.
- Gestionar platos, estaciones y disponibilidad desde administración.

El sistema no incluye pagos, facturación, reservas ni inventario avanzado, ya que se plantea como un módulo funcional independiente centrado en la comunicación sala-cocina.

---

## Estructura del repositorio

```text
kdskull/
|-- apps/
|   |-- sala/          # Aplicación utilizada por el personal de sala
|   |-- cocina/        # Aplicación utilizada por el personal de cocina
|   `-- admin/         # Aplicación de administración
|-- packages/
|   `-- shared/        # Código compartido: modelos, repositorios y lógica común
|-- database/
|   |-- firestore.rules
|   `-- firestore.indexes.json
|-- docs/
|   `-- deployment.md  # Guía detallada de despliegue
|-- firebase.json
`-- README.md
```

---

## Módulos principales

### Aplicación de sala

La aplicación de sala permite al personal seleccionar una mesa, añadir platos disponibles al pedido y enviarlo al sistema para que aparezca automáticamente en cocina.

Funcionalidades principales:

- Selección de mesa.
- Visualización de platos disponibles.
- Creación de pedidos.
- Resumen del pedido antes del envío.
- Envío del pedido a cocina.

---

### Aplicación de cocina

La aplicación de cocina permite visualizar los pedidos recibidos y organizarlos según la estación de trabajo correspondiente.

Funcionalidades principales:

- Selección de estación de cocina.
- Visualización de pedidos por estación.
- Filtrado de platos según la estación seleccionada.
- Cambio de estado de preparación.
- Actualización de información en tiempo real.

Estados principales de los platos:

```text
Pendiente -> En marcha -> Listo
```

---

### Aplicación de administración

La aplicación de administración permite configurar la información base necesaria para el funcionamiento del sistema.

Funcionalidades principales:

- Gestión de platos.
- Gestión de estaciones de cocina.
- Asociación de platos a estaciones.
- Control de disponibilidad de platos.

---

## Tecnologías utilizadas

El proyecto se ha desarrollado utilizando las siguientes tecnologías:

- **Flutter**: framework principal para el desarrollo de las aplicaciones cliente.
- **Dart**: lenguaje de programación utilizado por Flutter.
- **Firebase**: plataforma de servicios en la nube.
- **Cloud Firestore**: base de datos NoSQL utilizada para almacenamiento y sincronización en tiempo real.
- **Git**: sistema de control de versiones.
- **GitHub**: repositorio remoto del proyecto.

---

## Arquitectura general

KDSkull sigue una estructura modular separada en tres aplicaciones principales y un paquete compartido.

El paquete compartido contiene los elementos comunes del sistema:

- Modelos de datos.
- Repositorios.
- Lógica común de acceso a datos.
- Entidades compartidas entre sala, cocina y administración.

Esta estructura permite reutilizar código y mantener una separación clara entre las distintas partes del sistema.

---

## Modelo de datos principal

El sistema trabaja principalmente con las siguientes entidades:

- `Station`: representa una estación de trabajo dentro de la cocina.
- `Dish`: representa un plato disponible en el sistema.
- `Order`: representa un pedido realizado desde sala.
- `OrderItem`: representa cada plato incluido dentro de un pedido.

Colecciones principales utilizadas en Cloud Firestore:

```text
stations
dishes
orders
orderItems
```

---

## Requisitos previos

Para ejecutar el proyecto es necesario disponer de:

- Flutter SDK instalado.
- Dart SDK incluido con Flutter.
- Cuenta de Firebase.
- Proyecto Firebase configurado.
- Navegador compatible para ejecución web.
- Git instalado.

Para comprobar la instalación de Flutter:

```bash
flutter doctor
```

---

## Instalación del proyecto

Clonar el repositorio:

```bash
git clone https://github.com/CortezTech/kdskull.git
cd kdskull
```

Instalar dependencias en cada aplicación:

```bash
cd apps/sala
flutter pub get

cd ../cocina
flutter pub get

cd ../admin
flutter pub get
```

---

## Ejecución de las aplicaciones

Ejecutar la aplicación de sala:

```bash
cd apps/sala
flutter run -d chrome
```

Ejecutar la aplicación de cocina:

```bash
cd apps/cocina
flutter run -d chrome
```

Ejecutar la aplicación de administración:

```bash
cd apps/admin
flutter run -d chrome
```

---

## Configuración de Firebase

El proyecto utiliza Firebase y Cloud Firestore para almacenar y sincronizar la información en tiempo real.

Para ejecutar el sistema en otro entorno es necesario:

1. Crear un proyecto en Firebase.
2. Configurar Cloud Firestore.
3. Añadir la configuración de Firebase correspondiente a cada aplicación Flutter.
4. Ejecutar el proyecto con las dependencias instaladas.

Para despliegue de reglas e índices de Firestore, consulta la guía dedicada:

- `docs/deployment.md`

---

## Flujo principal de uso

El flujo básico del sistema es el siguiente:

1. El administrador configura las estaciones de cocina.
2. El administrador crea los platos y los asocia a una estación.
3. El personal de sala selecciona una mesa.
4. El personal de sala añade platos al pedido.
5. El pedido se envía al sistema.
6. Cocina visualiza los platos correspondientes a su estación.
7. Cocina actualiza el estado de preparación de cada plato.
8. La información queda sincronizada en tiempo real.

---

## Validación funcional

Durante el desarrollo se han validado los principales flujos del sistema:

- Creación de pedidos desde sala.
- Envío de pedidos a cocina.
- Visualización de pedidos por estación.
- Cambio de estado de platos.
- Gestión de disponibilidad.
- Creación y modificación de platos.
- Creación y modificación de estaciones.

Las pruebas realizadas han sido principalmente funcionales y manuales, centradas en comprobar que los flujos principales del sistema funcionan correctamente.

---

## Alcance del proyecto

KDSkull se centra exclusivamente en la gestión visual de pedidos entre sala y cocina.

Incluye:

- Gestión de pedidos.
- Gestión de platos.
- Gestión de estaciones.
- Sincronización en tiempo real.
- Control de disponibilidad.
- Separación por módulos.

No incluye:

- Pagos.
- Facturación.
- Reservas.
- Inventario avanzado.
- Integración con impresoras.
- Gestión multi-restaurante.
- Analítica avanzada.

Estas funcionalidades se consideran posibles líneas de evolución futura.

---

## Posibles mejoras futuras

Algunas mejoras planteadas para futuras versiones son:

- Autenticación por roles.
- Historial de pedidos cerrados.
- Notificaciones visuales o sonoras.
- Estadísticas básicas de tiempos de preparación.
- Soporte multi-restaurante.
- Integración con TPV o sistemas de facturación.

---

## Estado del proyecto

El proyecto implementa el flujo principal de un sistema KDS funcional:

- Gestión de platos y estaciones.
- Creación de pedidos desde sala.
- Visualización de pedidos en cocina.
- Filtrado por estación.
- Cambio de estado de platos.
- Control de disponibilidad.
- Sincronización mediante Cloud Firestore.

---

## Autor

**Ronny Cortez Cisneros**  
Ciclo Superior en Desarrollo de Aplicaciones Multiplataforma  
ThePower FP Oficial

---

## Licencia

All Rights Reserved © 2026 Ronny Cortez Cisneros

Este software es propiedad del autor. No se permite su copia, modificación, distribución ni uso sin autorización previa por escrito.
Consulta el archivo `LICENSE` para más detalles.
