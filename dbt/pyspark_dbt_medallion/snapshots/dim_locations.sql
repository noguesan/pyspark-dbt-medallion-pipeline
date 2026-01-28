{% snapshot dim_locations %}

{# 
Snapshot para mantener historial de cambios de clientes (SCD Type 2).
Cada vez que un cliente cambia, se guarda una nueva versión del registro.
#}

-- Configuración del snapshot (no poner comentarios dentro del config)
{{
    config(
        target_schema = 'gold',
        target_database = 'pysparkdbt',
        unique_key = 'location_id',
        strategy = 'timestamp',
        updated_at = 'last_updated_timestamp',
        dbt_valid_to_current = "to_date('9999-12-31')"
    )
}}


-- Fuente: tabla Silver de clientes
select *
from {{ source('source_silver', 'locations') }}

{% endsnapshot %}