# 📦 Pipeline ETL Sin Servidor con AWS Glue y Terraform

## Descripción General del Proyecto

Este proyecto demuestra la implementación y automatización de un pipeline de Extracción, Transformación y Carga (**ETL**) utilizando **AWS Glue** como motor de procesamiento sin servidor (PySpark) y **Terraform** para aprovisionar toda la infraestructura de soporte.

El principal objetivo es procesar archivos CSV crudos (`Raw Data`), aplicarles una transformación sencilla (añadir una columna de marca de tiempo) y almacenarlos en un formato optimizado (Parquet) en un bucket de datos procesados.

---

## 🏛️ Arquitectura Desplegada

El despliegue de Terraform crea la siguiente infraestructura en su cuenta de AWS:

| **Componente** | **Descripción** | **Uso** | 
| ----- | ----- | ----- | 
| **S3 Raw Bucket** | Almacenamiento de datos de entrada (CSV). | Origen de datos (`--S3_INPUT_PATH`). | 
| **S3 Processed Bucket** | Almacenamiento de datos transformados (Parquet). | Destino de datos (`--S3_OUTPUT_PATH`). | 
| **S3 Scripts Bucket** | Almacenamiento del código PySpark (`etl_job.py`). | Referencia para el Job de Glue. | 
| **IAM Role** | Rol de servicio asumido por Glue. | Otorga permisos para leer S3, escribir S3 y escribir logs en CloudWatch. | 
| **AWS Glue Job** | Trabajo ETL configurado (PySpark 4.0). | Motor de ejecución del script de transformación. | 

---

## 🚀 Despliegue y Configuración

### Prerrequisitos

Asegúrese de tener instalados y configurados los siguientes elementos:

1. **Terraform:** Para el aprovisionamiento de la infraestructura.

2. **AWS CLI:** Para la autenticación y la gestión de S3/Glue.

3. **Credenciales de AWS:** Configuradas localmente para que Terraform y la CLI puedan acceder a la cuenta (vía `aws configure` o variables de entorno).

### Estructura de Archivos

Asegúrese de que su directorio local tenga la siguiente estructura antes de ejecutar Terraform:

/glue_pipeline_project
├── main.tf             # Definición principal de Glue Job, IAM y S3
├── variables.tf        # Definición de variables de entrada (proyecto_nombre, región)
├── outputs.tf          # Salidas de Terraform (ARN de buckets, etc.)
├── sample_data.csv     # Archivo de prueba para la validación
└── glue_scripts/
└── etl_job.py      # Código PySpark con la lógica de transformación


### Pasos de Despliegue

1. **Inicializar Terraform:**

   ```bash
   terraform init
Planificar (Opcional, pero recomendado):

Bash

terraform plan -var="proyecto_nombre=datos_ventas"
Aplicar el Despliegue:

Bash

terraform apply -var="proyecto_nombre=datos_ventas"
Asegúrese de reemplazar datos_ventas por el nombre de proyecto que desee.

✅ Ejecución y Validación del Pipeline
Una vez que Terraform haya finalizado con éxito, el pipeline está listo, pero el Job de Glue debe ser activado.

1. Inyección de Datos
Utilice la AWS CLI para subir el archivo de prueba al bucket de entrada (RAW).

Bash

# Reemplace <NOMBRE_BUCKET_RAW> con el output de Terraform
aws s3 cp sample_data.csv s3://<NOMBRE_BUCKET_RAW>/input/sample_data.csv
2. Ejecutar el Job de Glue
Vaya a la consola de AWS Glue, busque el trabajo con el nombre datos_ventas-etl-job (o el nombre que haya definido en la variable proyecto_nombre) y haga clic en "Run job".

3. Verificar el Resultado
Monitoree el estado del Job en la consola.

Una vez que el Job finalice (SUCCEEDED), navegue al Processed Bucket (Output) en S3.

Debería encontrar un nuevo archivo Parquet. Este archivo contendrá los datos originales más la columna load_date añadida por el script PySpark, confirmando la transformación.

🗑️ Limpieza de Recursos
Para evitar costes, asegúrese de eliminar todos los recursos creados por Terraform:

Bash

terraform destroy -var="proyecto_nombre=datos_ventas"