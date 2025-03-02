provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

resource "aws_instance" "amazon_linux" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_id
  security_groups             = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  tags = {
    "Name" = "EC2-Instance"
  }
}

#ssh key pair for ec2 instance
resource "aws_key_pair" "web_key" {
  key_name   = var.prefix
  public_key = file("../${var.prefix}.pub")
}

resource "aws_security_group" "security_group" {
  name        = "allow_http_ssh_for_ec2_instance"
  description = "Allow HTTP,SSH and Kubernetes NodePort traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Add Kubernetes NodePort 30000
  ingress {
    description = "Kubernetes NodePort Service"
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow port 8080 for pod port-forwarding
  ingress {
    description = "Allow TCP 8080 for pod port-forwarding"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "K8s-EC2-sg"
  }
}

#Amazon Elastic Container Registry (ECR) repository
resource "aws_ecr_repository" "sql_repository" {
  name = "clo835-assignment2-sql-image"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "webapp_repository" {
  name = "clo835-assignment2-webapp-image"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}
