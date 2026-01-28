{% snapshot dim_customers %}

{# 
Snapshot para mantener historial de cambios de clientes (SCD Type 2).
Cada vez que un cliente cambia, se guarda una nueva versión del registro.
#}

{{
    config(
        -- Dónde se guardará la tabla histórica
        target_schema = 'gold',
        target_database = 'pysparkdbt',

        -- Identificador único del cliente
        unique_key = 'customer_id',

        -- Estrategia: detectar cambios usando timestamp
        strategy = 'timestamp',

        -- Columna que indica cuándo se actualizó el registro
        updated_at = 'last_updated_timestamp',

        -- Fecha máxima para registros vigentes (convención SCD2)
        dbt_valid_to_current = "to_date('9999-12-31')"
    )
}}

-- Fuente: tabla Silver de clientes
select *
from {{ source('source_silver', 'customers') }}

{% endsnapshot %}