# provider for data  
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# resource for aws db instance
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.user_name
  password             = var.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}


# resource for aws db subnet group

resource "aws_db_subnet_group" "default" {
  name       = "main"

  # tokyo subnets 
    subnet_ids = [var.aws_subnet_id]
    #subnet_ids = [aws_subnet.tokyo.id, aws_subnet.new_york.id, aws_subnet.london.id, aws_subnet.sao_paulo.id, aws_subnet.australia.id, aws_subnet.hong_kong.id, aws_subnet.california.id]

  tags = merge(var.common_tags, {
    Name = "${var.region_name}-db-subnet-group"
  })
}

# resource for aws db security group


resource "aws_security_group" "default" {
  name        = "default"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = []
    }

}

