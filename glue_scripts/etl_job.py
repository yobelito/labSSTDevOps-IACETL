# etl_job.py
# Script de PySpark para AWS Glue
# Lee datos de un bucket RAW, agrega una columna de timestamp y escribe en un bucket PROCESSED.

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import current_timestamp

# Obtiene argumentos pasados por Terraform/Glue
args = getResolvedOptions(sys.argv, [
    'JOB_NAME', 
    'S3_INPUT_PATH',
    'S3_OUTPUT_PATH'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 1. Leer los datos de la ubicación de entrada (RAW S3)
print(f"Leyendo datos de: {args['S3_INPUT_PATH']}")
datasource = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [args['S3_INPUT_PATH']], "recurse": True},
    format="csv",
    format_options={"withHeader": True, "separator": ","},
    transformation_ctx="datasource_ctx"
)

# Convertir a DataFrame de Spark para usar funciones de Spark SQL
df = datasource.toDF()

# 2. Transformación: Añadir una marca de tiempo de procesamiento
df_transformed = df.withColumn("processing_timestamp", current_timestamp())

# 3. Escribir los datos transformados de vuelta a S3 (PROCESSED S3)
print(f"Escribiendo datos a: {args['S3_OUTPUT_PATH']}")
dyf_output = DynamicFrame.fromDF(df_transformed, glueContext, "dyf_output")

glueContext.write_dynamic_frame.from_options(
    frame=dyf_output,
    connection_type="s3",
    connection_options={"path": args['S3_OUTPUT_PATH']},
    format="parquet", # Usamos Parquet para un formato de datos optimizado
    transformation_ctx="data_sink_ctx"
)

job.commit()
