import sys
from datetime import datetime

# 🚀 Si quieres usar GlueContext, SparkSession, etc., puedes descomentar estas líneas
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

if __name__ == "__main__":
    main()