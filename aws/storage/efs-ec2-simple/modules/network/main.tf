resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnets" {
  for_each = { for idx, az in var.availability_zones : idx => az }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.public_subnet.cidr_block
  availability_zone       = each.value.name
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnets" {
  for_each = { for idx, az in var.availability_zones : idx => az }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_subnet.cidr_block
  availability_zone = each.value.name
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnets

  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public_subnets

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id
}

resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private_subnets

  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat_gateway" {
  for_each = aws_route_table.private_rt

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}
