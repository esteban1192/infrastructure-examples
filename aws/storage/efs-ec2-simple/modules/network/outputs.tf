output "vpc_id" {
    value = aws_vpc.main.id
}

output "private_subnet_cidr_block" {
  value = aws_subnet.private_subnet.cidr_block
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}