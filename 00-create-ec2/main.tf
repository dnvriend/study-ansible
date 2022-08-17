#resource "aws_instance" "instance_a" {
#  ami                         = "ami-0c956e207f9d113d5"
#  associate_public_ip_address = true
#  instance_type               = "t3.nano"
#  key_name                    = aws_key_pair.generated_key.key_name
#  vpc_security_group_ids      = [aws_security_group.instance_a.id]
#  subnet_id                   = "subnet-916fe2f8"
#
#  tags = {
#    Name        = "instance_a"
#    Environment = "dev"
#    System      = "web"
#    Subsystem   = "api"
#  }
#}
#
#resource "aws_instance" "instance_b" {
#  ami                         = "ami-0c956e207f9d113d5"
#  associate_public_ip_address = true
#  instance_type               = "t3.nano"
#  key_name                    = aws_key_pair.generated_key.key_name
#  vpc_security_group_ids      = [aws_security_group.instance_a.id]
#  subnet_id                   = "subnet-916fe2f8"
#
#  tags = {
#    Name        = "instance_b"
#    Environment = "dev"
#    System      = "web"
#    Subsystem   = "api"
#  }
#}
#
#resource "aws_instance" "instance_c" {
#  ami                         = "ami-0c956e207f9d113d5"
#  associate_public_ip_address = true
#  instance_type               = "t3.nano"
#  key_name                    = aws_key_pair.generated_key.key_name
#  vpc_security_group_ids      = [aws_security_group.instance_a.id]
#  subnet_id                   = "subnet-916fe2f8"
#
#  tags = {
#    Name        = "instance_c"
#    Environment = "dev"
#    System      = "web"
#    Subsystem   = "api"
#  }
#}
#
#resource "aws_key_pair" "generated_key" {
#  key_name   = "instance-key"
#  public_key = file("./keypair.pub")
#}
#
#resource "aws_security_group" "instance_a" {
#  vpc_id = "vpc-4bef5022"
#  name   = "ssh-only"
#
#  egress = [
#    {
#      cidr_blocks = [
#        "0.0.0.0/0",
#      ]
#      description      = ""
#      from_port        = 0
#      ipv6_cidr_blocks = []
#      prefix_list_ids  = []
#      protocol         = "-1"
#      security_groups  = []
#      self             = false
#      to_port          = 0
#    },
#  ]
#
#  ingress = [
#    {
#      cidr_blocks = [
#        "0.0.0.0/0",
#      ]
#      description      = "allow-ssh"
#      from_port        = 22
#      ipv6_cidr_blocks = []
#      prefix_list_ids  = []
#      protocol         = "tcp"
#      security_groups  = []
#      self             = false
#      to_port          = 22
#    },
#  ]
#}
#
