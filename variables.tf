variable "number_of_workers" {  
    description = "Número de trabajadores para el Job Glue"
    type        = number
    default     = 2
}

variable "aws_access_key" {
  description = "Access Key ID de AWS."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret Access Key de AWS."
  type        = string
  sensitive   = true
}