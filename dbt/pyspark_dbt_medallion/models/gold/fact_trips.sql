{{ 
  config(
    materialized='incremental',
    unique_key='trip_id',
    database='pysparkdbt',
    schema='gold'
  ) 
}}

select
    -- Primary key de la tabla de hechos (fact)
    t.trip_id,

    -- Métricas del viaje (valores medibles)
    t.trip_start_time,
    t.trip_end_time,
    t.distance_km,
    t.fare_amount,

    -- Foreign keys hacia dimensiones (para análisis dimensional)
    t.customer_id,
    t.driver_id,
    t.vehicle_id,

    -- Columna de control para cargas incrementales
    t.last_updated_timestamp

from {{ ref('trips') }} t   -- Referencia al modelo Silver (modelo limpio y estandarizado)

{% if is_incremental() %}
where 
    -- Solo traer registros nuevos o modificados desde la última corrida
    t.last_updated_timestamp >
    (
        select coalesce(max(last_updated_timestamp), '1900-01-01')
        from {{ this }}   -- {{ this }} refiere a la tabla Gold ya creada
    )
{% endif %}
