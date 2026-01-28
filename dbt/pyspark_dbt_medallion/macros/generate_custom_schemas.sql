-- dbt necesita decidir en qué schema (esquema) guardar cada tabla.
-- “Si el modelo dice un schema específico, usalo.
-- Si no dice nada, usa el schema por defecto.”

{% macro generate_schema_name(custom_schema_name, node) -%}

    -- Obtiene el schema por defecto definido en profiles.yml
    {%- set default_schema = target.schema -%}

    -- Si el modelo NO define un schema propio
    {%- if custom_schema_name is none -%}

        -- Usa el schema por defecto del profile
        {{ default_schema }}

    {%- else -%}

        -- Si el modelo define schema (ej: silver, gold),
        -- se usa ese schema personalizado
        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
