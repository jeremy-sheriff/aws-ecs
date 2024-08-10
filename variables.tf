variable "region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "taskExecutionRole" {
  description = "ecsTaskExecutionRole"
  default     = "arn:aws:iam::975049979529:role/ecsTaskExecutionRole"
}

variable "DB_PASSWORD" {
  description = "DB PASSWORD"
  default     = "6130Password2024"
}

variable "DB_USER" {
  description = "DB USER"
  default     = "postgres"
}

variable "DB_PORT" {
  description = "DB PORT"
  default     = "5432"
}

variable "KC_DB_PASSWORD" {
  description = "KC_DB_PASSWORD"
  default     = "gitpass2016"
}

variable "KEY_CLOAK_DB" {
  description = "KEY_CLOAK_DB"
  default     = "postgres"
}

variable "KEY_ADMIN_PASSWORD" {
  description = "KEY_CLOAK_DB"
  default     = "bKKKAnuMRT9Qph3m"
}