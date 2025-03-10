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
  count                = 2
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.private_subnet.id
  ami                  = data.aws_ami.linux_2023.id
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