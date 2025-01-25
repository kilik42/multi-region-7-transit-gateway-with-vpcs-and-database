variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "region_name" {
  description = "Name of the region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = map(string)
}

variable "private_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = map(string)
}

variable "is_tokyo" {
  description = "Whether this VPC is for Tokyo region"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "syslog_az_index" {
  description = "Index of AZ for syslog server (Tokyo only)"
  type        = number
  default     = 0
}

variable "db_az_index" {
  description = "Index of AZ for database (Tokyo only)"
  type        = number
  default     = 1
}

