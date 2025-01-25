# modules/vpc/main.tf

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

locals {
  # For Tokyo region only - special handling
  tokyo_subnet_config = var.is_tokyo ? {
    syslog_az = var.availability_zones[0]  # First AZ for syslog
    db_az     = var.availability_zones[1]  # Second AZ for DB
  } : null

  # Calculate which AZs should have public subnets
  public_az_map = {
    for az in var.availability_zones : az => true
    if !var.is_tokyo || (
      az != try(local.tokyo_subnet_config.syslog_az, "") && 
      az != try(local.tokyo_subnet_config.db_az, "")
    )
  }

  # Determine which AZs get NAT gateways
  nat_gateway_map = {
    for az, is_public in local.public_az_map : az => {
      nat_subnet = az
    }
    if is_public
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-vpc"
  })
}

# Create private subnets in all AZs
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = lookup(
    var.private_cidr_blocks,
    "private${index(var.availability_zones, each.key) + 1}",
    cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, each.key) + 10)
  )

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-private-${index(var.availability_zones, each.key) + 1}"
    Type = "Private"
    Purpose = var.is_tokyo ? (
      each.key == local.tokyo_subnet_config.syslog_az ? "Syslog" :
      each.key == local.tokyo_subnet_config.db_az ? "Database" : "General"
    ) : "General"
  })
}

# Create public subnets only in allowed AZs
resource "aws_subnet" "public" {
  for_each = local.public_az_map

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = lookup(
    var.public_cidr_blocks,
    "public${index(var.availability_zones, each.key) + 1}",
    cidrsubnet(var.vpc_cidr, 8, index(var.availability_zones, each.key))
  )
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-public-${index(var.availability_zones, each.key) + 1}"
    Type = "Public"
  })
}

# Create Internet Gateway only if we have public subnets
resource "aws_internet_gateway" "this" {
  count  = length(local.public_az_map) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-igw"
  })
}

# Create EIP for NAT Gateway
resource "aws_eip" "nat" {
  for_each = local.nat_gateway_map
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-eip-${each.key}"
  })
}

# Create NAT Gateway in public subnets
resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateway_map

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

# Route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-private-rt"
  })
}

# Create a single route for private subnets through a single NAT gateway
resource "aws_route" "private_nat" {
  count = length(local.nat_gateway_map) > 0 ? 1 : 0
  
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[keys(aws_nat_gateway.this)[0]].id
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = length(aws_internet_gateway.this) > 0 ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this[0].id
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-public-rt"
  })
}

# Route table associations
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Security group for web servers
resource "aws_security_group" "web" {
  name        = "${var.region_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}