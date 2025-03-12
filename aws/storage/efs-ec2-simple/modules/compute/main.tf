resource "aws_iam_role" "instances_role" {
  name = "ssm-instance-role"

  assume_role_policy = file("${path.module}/ec2-assume-role-policy.json")
}

resource "aws_iam_policy" "describe_azs" {
  name        = "DescribeAvailabilityZonesPolicy"
  description = "Allows describing availability zones"

  policy = file("${path.module}/describe-azs-policy.json")
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
  for_each             = { for idx, subnet_id in var.subnet_ids : idx => subnet_id }
  instance_type        = var.instance_type
  subnet_id            = each.value
  ami                  = data.aws_ami.linux_2023.id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  # user_data = file("${path.module}/user-data.sh")
  user_data = templatefile("${path.module}/user-data.sh", { efs_id = var.efs_id })

  tags = {
    Name = "EC2-Instance-${each.value}"
  }
}