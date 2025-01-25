# create var user_name and password as string

variable "db_name" {
    description = "DB name"
    type = string
    default = "mydatabase"
}

variable "db_instance_class" {
    description = "Database instance type"
    type = string
    default = "db.t3.micro"
}

variable "aws_subnet_id" {
  description = "The subnet id for the database."
  type        = string 
}

variable "db_engine" {
    description = "DB engine"
    type = string
    default  = "postgres" 
}

variable "db_engine_version" {
    description = "database engine version"
    type = string
    default = "13.4"
}

variable "db_allocated_storage" {
    description = "Allocated storage for DB (in GB)"
    type = number
    default = 20
}

variable "storage_encrypted" {
    description = "Whether to encrypot the DB storage"
    type = bool
    default = true
}

variable "user_name" {
  description = "The username for the database."
  type        = string
}

variable "password" {
  description = "The password for the database."
  type        = string
}


variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  
}

variable "region_name" {
  description = "The name of the region."
  type        = string
}

variable "multi_az" {
    description  = "Whether to deploy the DB in a multi-AZ configuration"
    type = bool
    default = false
}