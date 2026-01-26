from typing import List
from pyspark.sql import DataFrame
from pyspark.sql.window import Window
from pyspark.sql.functions import concat, col, row_number, current_timestamp
from delta.tables import DeltaTable

class transformations:

    def dedup(self, df: DataFrame, dedup_cols: List, cdc: str, order: str = "desc"):
        """
        Deduplica un DataFrame de Spark conservando un único registro por entidad,
        utilizando una columna temporal como criterio de desempate.

        La función agrupa los registros según las columnas definidas en `dedup_cols`
        y, dentro de cada grupo, ordena los registros por la columna `cdc`.
        El orden puede ser ascendente ('asc') o descendente ('desc', valor por defecto).

        En columnas de tipo fecha o timestamp:
        - 'asc'  → conserva el registro más antiguo
        - 'desc' → conserva el registro más reciente
        ________________________
        Parámetros:
        df : DataFrame
            DataFrame de entrada que puede contener registros duplicados.

        dedup_cols : List
            Lista de nombres de columnas que definen la clave lógica de deduplicación.

        cdc : str
            Nombre de la columna utilizada para ordenar los registros dentro de cada grupo.

        order : str, opcional
            Define el orden de clasificación:
            - 'asc'  (por defecto)
            - 'desc'
        ________________________
        Retorna:
        DataFrame
            DataFrame deduplicado, con un único registro por clave lógica.
        """
        # Construcción de la clave de deduplicación
        df = df.withColumn("dedupKey", concat(*[col(c) for c in dedup_cols]))

        # Definición del orden
        if order.lower() == "asc":
            order_col = col(cdc).asc()
        else:
            order_col = col(cdc).desc()

        # Numeración de filas por grupo
        df = df.withColumn("dedupCounts", row_number().over(Window.partitionBy("dedupKey").orderBy(order_col)))

        # Filtrado del registro válido
        df = df.filter(col("dedupCounts") == 1)

        # Limpieza de columnas auxiliares
        df = df.drop("dedupKey", "dedupCounts")

        return df
    
    def process_timestamp(self,df):
        """
        Agrega una columna de auditoría con la marca temporal del procesamiento.

        La función incorpora la columna `process_timestamp`, que registra el
        momento exacto en el que el DataFrame es procesado dentro del pipeline.
        Esta columna es útil para:
        - Auditoría de datos
        - Trazabilidad del procesamiento
        - Análisis de latencias y reprocesos

        ________________________
        Parámetros:
        df : DataFrame
            DataFrame de entrada al que se le agregará la columna de timestamp
            de procesamiento.

        ________________________
        Retorna:
        DataFrame
            DataFrame original con una nueva columna `process_timestamp`
            de tipo timestamp.
        """
        df = df.withColumn("process_timestamp", current_timestamp())

        return df
        
    def upsert(self, spark, df, key_cols, table, cdc):
        """
        Realiza una operación de UPSERT (MERGE) sobre una tabla Delta.

        La función sincroniza los datos del DataFrame de entrada con una tabla
        Delta existente en la capa Silver, aplicando una lógica de:
        - UPDATE: cuando el registro ya existe y el valor de la columna CDC
        es mayor o igual al almacenado.
        - INSERT: cuando el registro no existe en la tabla destino.

        La condición de unión se construye dinámicamente a partir de las
        columnas clave definidas en `key_cols`.

        ________________________
        Parámetros:
        spark : SparkSession
            Sesión activa de Spark necesaria para acceder a la tabla Delta.

        df : DataFrame
            DataFrame de origen que contiene los datos a insertar o actualizar.

        key_cols : List
            Lista de columnas que definen la clave primaria lógica
            utilizada para el MERGE.

        table : str
            Nombre de la tabla Delta (capa Silver) sobre la que se ejecuta
            el UPSERT.

        cdc : str
            Nombre de la columna de control de cambios (Change Data Capture),
            utilizada para determinar si un registro debe actualizarse.

        ________________________
        Retorna:
        int
            Retorna 1 si la operación se ejecuta correctamente.
        """

        # Construcción dinámica de la condición de MERGE
        merge_condition = " AND ".join(
            [f"src.{i} = trg.{i}" for i in key_cols]
        )

        # Referencia a la tabla Delta destino
        dlt_obj = DeltaTable.forName(
            spark,
            f"pysparkdbt.silver.{table}"
        )

        # Ejecución del MERGE (UPSERT)
        dlt_obj.alias("trg") \
            .merge(df.alias("src"), merge_condition) \
            .whenMatchedUpdateAll(condition=f"src.{cdc} >= trg.{cdc}") \
            .whenNotMatchedInsertAll() \
            .execute()

        return 1
    
