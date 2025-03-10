provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
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
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "efs_sg" {
  vpc_id = aws_vpc.main.id
  
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet.cidr_block]
  }
}

resource "aws_efs_file_system" "efs" {}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_iam_role" "instances_role" {
  name = "ssm-instance-role"
  
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "describe_azs" {
  name        = "DescribeAvailabilityZonesPolicy"
  description = "Allows describing availability zones"
  
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ec2:DescribeAvailabilityZones",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "ssm_core" {
  name       = "ssm-core-attachment"
  roles      = [aws_iam_role.instances_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "efs_read_write" {
  name       = "efs-read-write-attachment"
  roles      = [aws_iam_role.instances_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
}

resource "aws_iam_policy_attachment" "describe_azs_attachment" {
  name       = "describe-azs-attachment"
  roles      = [aws_iam_role.instances_role.name]
  policy_arn = aws_iam_policy.describe_azs.arn
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.instances_role.name
}

data "aws_ami" "linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "ec2_instances" {
  count         = 2
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet.id
  ami           = data.aws_ami.linux_2023.id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf -y install amazon-efs-utils
              if echo $(python3 -V 2>&1) | grep -e "Python 3.6"; then
                  sudo wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
              elif echo $(python3 -V 2>&1) | grep -e "Python 3.5"; then
                  sudo wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
              elif echo $(python3 -V 2>&1) | grep -e "Python 3.4"; then
                  sudo wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
              else
                  sudo apt-get -y install python3-distutils
                  sudo wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
              fi
              sudo python3 /tmp/get-pip.py
              sudo pip3 install botocore || sudo /usr/local/bin/pip3 install botocore
              mkdir -p /mnt/efs
              sudo mount -t efs -o tls ${aws_efs_file_system.efs.id}:/ /mnt/efs
              EOF
  
  tags = {
    Name = "EC2-Instance-${count.index + 1}"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
}
