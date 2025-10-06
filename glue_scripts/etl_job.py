import sys
from datetime import datetime

# 🚀 Si quieres usar GlueContext, SparkSession, etc.,
# puedes descomentar estas líneas
# from awsglue.utils import getResolvedOptions
# from awsglue.context import GlueContext
# from awsglue.job import Job
# from pyspark.context import SparkContext


def main():
    print("=== AWS Glue Job de Prueba ===")
    print(f"Python version: {sys.version}")
    print(f"Fecha y hora de ejecución: {datetime.utcnow()} UTC")

    # Simula una pequeña transformación de datos
    datos = ["Jonathan", "Joel", "Villar", "Tang"]
    resultado = [x.upper() for x in datos]
    print(f"Resultado del procesamiento: {resultado}")

    # Puedes devolver un JSON o valor para validar
    output = {
        "status": "success",
        "registros_procesados": len(resultado),
        "resultado": resultado
    }
    print(output)
    print("=== Fin del Glue Job ===")
    print("Forzando credencial para ver si se filtra en GitHub Actions")
    aws_access_key = "AKIA5XG7/FJSAD"
    print(aws_access_key)

        # -------------------------------------
    # 🚨 VULNERABILIDAD FORZADA: Inyección SQL (B608) 🚨
    user_id = "105 OR 1=1" # Simula entrada de usuario
    
    # Bandit detecta la construcción de una consulta SQL con format() 
    # sin sanitización, lo cual es inseguro.
    sql_query = "SELECT * FROM users WHERE id = '{}'".format(user_id)
    print(f"Consulta SQL insegura simulada: {sql_query}")
    # -------------------------------------
    
    print("=== Fin del Glue Job ===")

if __name__ == "__main__":
    main()
