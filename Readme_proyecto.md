# 📘 Pipeline de Datos End‑to‑End con Databricks + dbt

**Proyecto:** `pysparkdbt_proyect_internal`

---

## 1. Introducción — Función real del proyecto

Este proyecto implementa un **pipeline de datos end‑to‑end**, cuyo objetivo es transformar datos crudos en información analítica confiable, lista para ser utilizada en **reportes, dashboards, análisis de negocio y modelos predictivos**.

En términos simples, el proyecto busca:

> Convertir datos desordenados en información estructurada, confiable y útil para la toma de decisiones.

El diseño sigue **buenas prácticas modernas de Data Engineering y Analytics Engineering**, combinando **Databricks, PySpark y dbt**, e implementando una **arquitectura Medallion (Bronze / Silver / Gold)**.

---

## 2. Función general del pipeline

El pipeline cubre todo el ciclo de vida del dato:

1. Ingesta de datos crudos
2. Limpieza y estandarización
3. Transformación analítica
4. Versionado histórico
5. Modelado dimensional
6. Preparación para consumo en **BI / Analytics / Machine Learning**

---

## 3. Flujo del procesamiento de datos

### 🧱 Paso 1 — Carga de datos crudos a Databricks (Capa Bronze)

Se cargaron datos sin procesar en la capa **Bronze**, preservando su estructura original.

**Características:**

* No se aplica lógica de negocio
* No se eliminan registros
* Se mantiene el dato original como **fuente de verdad**

🎯 **Objetivo:** garantizar trazabilidad y posibilidad de reprocesamiento.

---

### 🧼 Paso 2 — Limpieza y estandarización en Silver (Databricks + PySpark)

En la capa **Silver** se aplicaron transformaciones para mejorar la calidad del dato:

✔ Limpieza de registros inválidos
✔ Normalización de formatos
✔ Eliminación de inconsistencias
✔ Deduplicación
✔ Estandarización de columnas
✔ Control de cambios (CDC)
✔ UPSERT sobre **Delta Lake**

🎯 **Objetivo:** convertir datos crudos en datos confiables listos para modelado analítico.

---

### 🔗 Paso 3 — Integración de Silver con dbt

Se conectó **dbt a Databricks** para separar responsabilidades:

| Herramienta          | Rol                                 |
| -------------------- | ----------------------------------- |
| Databricks + PySpark | Transformaciones pesadas y limpieza |
| dbt                  | Modelado analítico y semántico      |

🎯 Esto implementa una **arquitectura moderna, modular y escalable**.

---

### 🧱 Paso 4 — Modelo Silver en dbt (modelo `trips` como puente estructural)

El modelo `trips` en dbt:

* Replica los datos de Silver
* No agrega lógica nueva
* Mantiene trazabilidad entre capas

🎯 **Objetivo:** servir como base estructural para la capa Gold.

---

### ⭐ Paso 5 — Construcción de la capa Gold (`fact_trips`)

Se creó la tabla **`fact_trips`**, que funciona como **tabla de hechos central**.

✔ Selección de columnas relevantes
✔ Implementación de carga incremental
✔ Optimización para consultas analíticas
✔ Preparación para dashboards y BI

🎯 **Objetivo:** generar una estructura analítica eficiente y escalable.

---

## 4. ¿Qué es una Tabla de Hechos (Fact Table)?

Una **tabla de hechos** almacena eventos medibles del negocio.

**Características:**

* Representa acciones reales (ej. viajes)
* Contiene métricas numéricas
* Se conecta con dimensiones (clientes, conductores, vehículos, etc.)

📌 En este proyecto:

Cada fila de `fact_trips` representa un **viaje real**.

Permite responder preguntas como:

* ¿Cuántos viajes hubo por período?
* ¿Cuánto dinero generó cada conductor?
* ¿Qué clientes generan más ingresos?

---

## 5. Versionado histórico — Slowly Changing Dimensions Type 2 (Snapshots)

Se implementó **SCD Tipo 2** usando **dbt Snapshots** para mantener historial de cambios en dimensiones.

**Dimensiones versionadas:**

* Customers
* Drivers
* Locations
* Payments
* Vehicles

🎯 **Objetivo:** conservar el estado pasado de los datos para análisis históricos.

---

### 🧠 Problema sin SCD2

Si un cliente cambia de ciudad y el dato se sobrescribe:

* Se pierde historial
* Los reportes históricos quedan incorrectos

---

### ✅ Solución SCD Tipo 2

Cada cambio genera una **nueva versión del registro**, conservando el histórico.

**Ejemplo:**

| customer_id | city         | valid_from | valid_to   | current |
| ----------- | ------------ | ---------- | ---------- | ------- |
| 101         | La Plata     | 2022‑01‑01 | 2024‑03‑10 | false   |
| 101         | Buenos Aires | 2024‑03‑11 | 9999‑12‑31 | true    |

---

## 6. Función práctica del proyecto

### 🎯 Función técnica

✔ Pipeline moderno de Analytics Engineering
✔ Arquitectura Medallion
✔ Transformaciones con PySpark
✔ Modelado analítico con dbt
✔ Snapshots SCD Tipo 2
✔ Cargas incrementales (CDC)
✔ Modelo dimensional (Star Schema)

---

### 🎯 Función de negocio

El proyecto permite:

* Analizar viajes
* Medir ingresos
* Evaluar desempeño de conductores
* Analizar comportamiento de clientes
* Construir dashboards de movilidad
* Generar reportes financieros
* Preparar datos para Machine Learning

---

## 7. Objetivo final del pipeline

El estado ideal del pipeline es:

1. Ingesta automática de datos
2. Procesamiento **Bronze → Silver** en Databricks
3. Transformación **Silver → Gold** en dbt
4. Consumo por **BI / Dashboards**
5. Orquestación automática por schedule

🎯 **Un pipeline automatizado, productivo y escalable de punta a punta.**

---

## 8. En una frase profesional

> **“Construí un pipeline end‑to‑end que transforma datos crudos en modelos analíticos optimizados, manteniendo historial completo de cambios y aplicando buenas prácticas modernas de ingeniería de datos.”**

---

Si querés, puedo mejorar este README para:

* Que se vea **nivel portfolio profesional**
* Agregar **arquitectura visual (diagramas)**
* Incluir **sección de instalación y ejecución**
* Adaptarlo para **LinkedIn, GitHub y entrevistas**
