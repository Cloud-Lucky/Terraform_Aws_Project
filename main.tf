#Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table_association" "rt1a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_route_table_association" "rt1b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_security_group" "ssh-sg" {
  name = "ssh-sg"
  vpc_id = aws_vpc.myvpc.id
}


resource "aws_security_group" "LB_sg" {
  name   = "LB-sg"
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_vpc_security_group_ingress_rule" "LB_sg_ingress" {
  security_group_id = aws_security_group.LB_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "LB_sg_egress" {
  security_group_id = aws_security_group.LB_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_vpc_security_group_ingress_rule" "web_sg_ingress" {
  security_group_id = aws_security_group.web_sg.id
  referenced_security_group_id = aws_security_group.LB_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "ssh_sg_ingress" {
  security_group_id = aws_security_group.ssh-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "outbound1" {
  security_group_id = aws_security_group.web_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "example1" {
  ami                    = var.ami_id
  key_name               = var.key_name
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.ssh-sg.id,aws_security_group.web_sg.id]
  user_data_base64       = base64encode(file("userdata.sh"))
}
resource "aws_instance" "example2" {
  ami                    = var.ami_id
  key_name               = var.key_name
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.ssh-sg.id,aws_security_group.web_sg.id]
  user_data_base64       = base64encode(file("userdata1.sh"))
}

# Creating S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "laxmireddy-terra"
}
resource "aws_s3_account_public_access_block" "s3_bucket" {
  block_public_acls = true
}

# Creating LB

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.LB_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}
resource "aws_lb_target_group" "app_lb_tg" {
  name     = "app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.app_lb_tg.arn
  target_id        = aws_instance.example1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.app_lb_tg.arn
  target_id        = aws_instance.example2.id
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}

output "Loadbalancedns" {
  value = aws_lb.app_lb.dns_name
}

resource "aws_dynamodb_table" "s3_table" {
  name = "s3-table-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockIp"
  attribute {
    name = "LockIp"
    type = "S"
  }
}

