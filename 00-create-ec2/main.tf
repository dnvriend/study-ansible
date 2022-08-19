locals {
  spot_price = "0.0018" # normal $0.0060 so 3x more expensive per hour

  bastion_tags = {
    Name        = "bastion"
    Environment = "dev"
    System      = "ops"
    Subsystem   = "bastion"
  }

  instance_b_tags = {
    Name        = "instance_b"
    Environment = "dev"
    System      = "web"
    Subsystem   = "api"
  }

  instance_c_tags = {
    Name        = "instance_c"
    Environment = "dev"
    System      = "web"
    Subsystem   = "api"
  }
}
output "bastion_public_ip" {
  value = aws_spot_instance_request.bastion.public_ip
}

output "bastion_spot_price" {
  value = aws_spot_instance_request.bastion.spot_price
}

output "instance_b_private_ip" {
  value = aws_spot_instance_request.instance_b.private_ip
}

output "instance_b_spot_price" {
  value = aws_spot_instance_request.instance_b.spot_price
}

output "instance_c_private_ip" {
  value = aws_spot_instance_request.instance_c.private_ip
}

output "instance_c_spot_price" {
  value = aws_spot_instance_request.instance_c.spot_price
}

resource "aws_spot_instance_request" "bastion" {
  ami                         = "ami-0c956e207f9d113d5"
  spot_price                  = local.spot_price
  wait_for_fulfillment        = true
  associate_public_ip_address = true
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.instance_a.id]
  subnet_id                   = "subnet-916fe2f8"
}

resource "aws_ec2_tag" "bastion" {
  resource_id = aws_spot_instance_request.bastion.spot_instance_id

  for_each = local.bastion_tags
  key      = each.key
  value    = each.value
}

resource "aws_spot_instance_request" "instance_b" {
  ami                         = "ami-0c956e207f9d113d5"
  spot_price                  = local.spot_price
  wait_for_fulfillment        = true
  associate_public_ip_address = true
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.instance_a.id]
  subnet_id                   = "subnet-916fe2f8"

  tags = {
    Name        = "instance_b"
    Environment = "dev"
    System      = "web"
    Subsystem   = "api"
  }
}

resource "aws_ec2_tag" "instance_b" {
  resource_id = aws_spot_instance_request.instance_b.spot_instance_id

  for_each = local.instance_b_tags
  key      = each.key
  value    = each.value
}


resource "aws_spot_instance_request" "instance_c" {
  ami                         = "ami-0c956e207f9d113d5"
  spot_price                  = local.spot_price
  wait_for_fulfillment        = true
  associate_public_ip_address = true
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.instance_a.id]
  subnet_id                   = "subnet-916fe2f8"

}

resource "aws_ec2_tag" "instance_c" {
  resource_id = aws_spot_instance_request.instance_c.spot_instance_id

  for_each = local.instance_c_tags
  key      = each.key
  value    = each.value
}

resource "aws_key_pair" "generated_key" {
  key_name   = "instance-key"
  public_key = file("./keypair.pub")
}

resource "aws_security_group" "instance_a" {
  vpc_id = "vpc-4bef5022"
  name   = "ssh-only"

  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow-ssh"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
  ]
}
