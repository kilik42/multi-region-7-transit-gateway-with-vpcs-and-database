# output for instance id

output "aws_db_instance_id" {
  value = aws_db_instance.default.id
}


# output for instance endpoint
output "aws_db_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}


####### might need this stuff

# output "db_subnet_group_id" 
output "db_subnet_group_id" {
    value = aws_db_subnet_group.default.id
}

# output "db_subnet_group_name" 
output "db_subnet_group_name" {
    value = aws_db_instance.default.db_subnet_group_name.id
}


# output "db_subnet_group_vpc_id" 

output "db_subnet_group_vpc_id" {
    value = aws_db_subnet_group_vpc.id
}

# output "db_subnet_group_subnet_ids" 

output "db_subnet_group_subnet_ids" {
    value = aws_db_subnet_group_subnet_ids.default.id

}