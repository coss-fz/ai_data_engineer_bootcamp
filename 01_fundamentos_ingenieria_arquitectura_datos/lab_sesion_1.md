# Laboratorio: Sesión 01 - Fundamentos y Arquitectura de Datos

**Caso:** ShopStart es una empresa que vende CRMs on Cloud para empresas pequeñas con modalidad de suscripción. En los últimos 2 meses se han incrementado las bajas de clientes de 5 a 7%. La empresa no ha identificado la causa por lo que decide llamar a su equipo de data y analytics.

**Objetivo de negocio:**  Reducir las bajas de clientes del 7% a 4%.

La empresa cuenta con los siguientes sistemas:
- BD Relacionales
    - Sistema de Atención al Cliente (SACT): Interacciones web de clientes: quejas, reclamos y consultas.
    - Sistema de cobranzas y pagos (OAC): Facturas y pagos mensuales.
- Información externa del call center proveedor
    - Llamadas de quejas de clientes (Solo se puede acceder mediante APIs del proveedor).
- BD No Relacional (documentaria)
    - CRM: Sistema de transacciones, clientes y productos.

Te encargan la tarea de diseñar la arquitectura de datos conceptual que soporte la organice los datos provenientes de los sistemas y genere estructuras de consumo para detectar la causa raíz.


---


## 1. Diseño de Arquitectura de Datos Conceptual
Para abordar el objetivo de negocio de reducir las bajas de clientes, se propone una arquitectura basada en un **Data Lakehouse** moderno (utilizando componentes como Google Cloud Storage y BigQuery) estructurada en capas de procesamiento.

### Flujo de Datos y Zona de Ingesta
- **Fuentes de Origen:**
    - **SACT (Relacional):** Datos de quejas y consultas.
    - **OAC (Relacional):** Facturación y pagos.
    - **Call Center (API):** Audio/Texto de llamadas de quejas.
    - **CRM (NoSQL):** Transacciones, perfiles de clientes y productos.
- **Ingesta:** Procesos de extracción mediante conectores para aplicaciones y bases de datos, así como configuraciones de conexión a APIs. El procesamiento se haría según necesidades, código puro (o frameworks) para extracciones de APIs e integradores para bases de datos relacionales.

### Zona de Almacenamiento
- **Capa Raw:**
    - **¿Qué se hace?** Se guardan en su formato original (JSON, CSV, SQL, etc) sin modificaciones, para asegurar trazabilidad.
    - **Beneficios:** Permite la recuperación ante fallos de transformación y garantiza trazabilidad absoluta para auditorías.
    - **Destino de data no estructurada** Se guardaría en un **Storage (Object Storage)** como Google Cloud Storage, esto para optimizar costos y escalabilidad.
- **Capa Master:**
    - **Unión de datos:** Uniría la información del CRM con el historial de pagos (OAC) y sus interacciones de quejas (SACT y Call Center) para crear una visión 360° del funcionamiento de la empresa.
    - **Detalle:** Nivel de detalle máximo (granularidad transaccional) para permitir análisis de causa raíz profundos.
- **Capa BI:**
    - **Modelo:** Utilizaría **Modelos Estrella** para flexibilidad en el autoservicio y ejecución de queries comunes, así como **Tablones denormalizados** para reportes específicos de alta velocidad.

### Zona de Procesamiento
- **¿ETL o ELT?** Se recomienda **ELT (Extract, Load, Transform)**.
    - **Escenario:** En entornos de nube, es más eficiente cargar los datos primero al Storage/DW y luego transformarlos usando la potencia de cómputo distribuida (como BigQuery o Spark), lo que reduce tiempos de carga y costos de infraestructura intermedia.

### Taxonomía y Dominios
- **Dominios:** Clientes, Facturación, Soporte Técnico.
- **Subdominios:** Pagos, Reclamos Web, Reclamos Call Center.
- **Nomenclatura Sugerida:** `[Proyecto]_[Área]_[Dominio]_[Tabla]_[Tipo]` (Ej: `ss_contabilidad_facturacion_quejas_fct`).


---


## 2. Preguntas Estratégicas y de Gestión
- **Cambios de Tecnologías -** Se mitiga utilizando formatos abiertos como `parquet` en la capa Raw, lo que facilita migrar entre nubes o herramientas de procesamiento sin perder la estructura de los datos.
- **Convivencia de dos ERPs -** Se implementa una capa master agnóstica, donde la arquitectura de datos abstrae las diferencias de los dos sistemas operativos mediante procesos de mapeo y estandarización, integrándolos y entregando al negocio una tabla única independientemente de si el dato viene del ERP antiguo o nuevo.
- **Cumplimiento y Respeto de la Arquitectura -** Se debería implementar un catálogo de datos y políticas de gobernanza, así como la automatización de validaciones en los procesos, impidiendo que los datos que no respeten la nomenclatura o calidad pasen de la capa Raw a la Master.
- **Reprocesamientos -** Se manejaría directamente desde los integradosres o bloques de código, permitiendo condicionales que den la posibilidad de realizar reprocesamientos a demanda, siguiendo los estándares de calidad.
- **Calidad y Disponibilidad:** Implementando procesos de checkpointing, indexación y particionamiento por fecha en las cargas, asegurando que si un proceso falla, se pueda retomar sin duplicar datos y manteniendo la consistencia.