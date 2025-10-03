#1 Configuración del proveedor AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

#2 Creación de los s3 buckets

# Bucket capa RAW

resource "aws_s3_bucket" "raw_bucket" {
  bucket = "sst-raw-data-jvt"
  tags = {
    Name        = "Raw Data Bucket"
    Environment = "Dev"
    Project     = "Lab-SST-DevOps"
  }
  
}
# Bucket capa PROCESSED
resource "aws_s3_bucket" "processed_bucket" {
  bucket = "sst-processed-data-jvt"
  tags = {
    Name        = "PROCESSED Data Bucket"
    Environment = "Dev"
    Project     = "Lab-SST-DevOps"
  }
  
}

#Bucket para los scripts de Glue
resource "aws_s3_bucket" "glue_scripts_bucket" {   
  bucket = "sst-glue-scripts-jvt"
  tags = {
    Name        = "Glue Scripts Bucket"
    Environment = "Dev"
    Project     = "Lab-SST-DevOps"
  }
  
}

#3 Creación del IAM Role con las políticas necesarias

resource "aws_iam_role" "glue_service_role" {
  name = "glue-service-role-jvt"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
}

resource "aws_iam_policy" "glue_access_policy" {
  name        = "glue-access-policy-jvt"
  description = "Policy to allow Glue access to S3 buckets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        #permitir acceso a los buckets S3
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.raw_bucket.arn,
          "${aws_s3_bucket.raw_bucket.arn}/*",
          aws_s3_bucket.processed_bucket.arn,
          "${aws_s3_bucket.processed_bucket.arn}/*",
          aws_s3_bucket.glue_scripts_bucket.arn,
          "${aws_s3_bucket.glue_scripts_bucket.arn}/*"
        ]
      },
      #permitir acceso a CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_access_policy.arn
}


#4 Creación del Job Glue
#4.1 Subir archivo python a S3

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.glue_scripts_bucket.bucket
  key    = "glue_scripts/etl_job.py"  # Ruta dentro del bucket donde se almacenará el script
  source = "glue_scripts/etl_job.py"  # Asegúrate de tener este archivo en el mismo directorio que tu archivo .tf
  etag   = filemd5("glue_scripts/etl_job.py")
}

#4.2 Crear el Job Glue

resource "aws_glue_job" "etl_job" {
  name     = "etl-job-JVT"
  role_arn = aws_iam_role.glue_service_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts_bucket.bucket}/${aws_s3_object.glue_script.key}"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language" = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics" = ""
    "--enable-spark-ui" = ""
    "--spark-event-logs-path" = "s3://${aws_s3_bucket.glue_scripts_bucket.bucket}/spark-event-logs/"
    "--TempDir" = "s3://${aws_s3_bucket.glue_scripts_bucket.bucket}/temp/"

    #variables de entorno para el script
    "--JOB_NAME" = "etl-job-JVT"
    "--S3_INPUT_PATH" = "s3://${aws_s3_bucket.raw_bucket.bucket}/input/"     
    "--S3_OUTPUT_PATH" = "s3://${aws_s3_bucket.processed_bucket.bucket}/output/" 
  }
  glue_version       = "5.0"
  number_of_workers  = var.number_of_workers
  worker_type        = "G.1X"
  max_retries        = 1
  timeout            = 10
  tags = {
    Name        = "ETL Job"
    Environment = "Dev"
    Project     = "Lab-SST-DevOps"
  }
}