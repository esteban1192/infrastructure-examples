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