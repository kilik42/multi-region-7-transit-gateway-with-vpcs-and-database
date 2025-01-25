output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "syslog_subnet_id" {
  value = var.is_tokyo ? [
    for az, subnet in aws_subnet.private : 
    subnet.id if az == var.availability_zones[0]
  ][0] : null
}

output "db_subnet_id" {
  value = var.is_tokyo ? [
    for az, subnet in aws_subnet.private : 
    subnet.id if az == var.availability_zones[1]
  ][0] : null
}

output "security_group_id" {
  value = aws_security_group.web.id
}