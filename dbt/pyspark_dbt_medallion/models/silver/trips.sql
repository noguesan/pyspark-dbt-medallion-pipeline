{{ 
  config(
    materialized='incremental',
    unique_key='trip_id',
    enabled=true
  ) 
}}

-- ==========================================================
-- MODELO: SILVER - TRIPS
-- CAPA: SILVER (Datos limpios y estructurados)
-- OBJETIVO:
-- Transformar los datos crudos de Bronze en una tabla confiable,
-- optimizada y lista para análisis posteriores en Gold.
-- ==========================================================

-- Lista de columnas que vamos a seleccionar
{# 
Se usa Jinja para evitar repetir columnas en el SELECT.
Jinja corresponde a lo que está entre {{ }} o {% %}.
#}
{% set cols = [
    'trip_id',
    'vehicle_id',
    'customer_id',
    'driver_id',
    'trip_start_time',
    'trip_end_time',
    'distance_km',
    'fare_amount',
    'last_updated_timestamp'
] %}

SELECT
    -- Se genera dinámicamente el SELECT recorriendo la lista de columnas
    {% for col in cols %}
        {{ col }}
        {% if not loop.last %}
            ,
        {% endif %}
    {% endfor %}
FROM
    -- Fuente definida en sources.yml (tabla bronze)
    {{ source("source_bronze", "trips") }}

-- Lógica incremental: solo se ejecuta si la tabla ya existe
{% if is_incremental() %}
WHERE
    -- Trae solo registros nuevos o actualizados
    last_updated_timestamp >
        (
            SELECT
                coalesce(MAX(last_updated_timestamp), '1900-01-01')
            FROM {{ this }}   -- {{ this }} refiere a la tabla destino del modelo
        )
{% endif %}