output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_cidr_blocks" {
  value = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}
