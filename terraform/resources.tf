provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.57"
  profile = "terraform-user"
}

# Create a VPC with mentioned CIDR.
resource "aws_vpc" "EKS-VPC" {
  cidr_block       = var.EKS-vpc-cidr
  instance_tenancy = "default"

  tags = {
    Name = "EKS VPC"
  }
}
# Create Internet Gateway

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.EKS-VPC.id

  tags = {
    Name = "Internet-Gateway-EKS"
  }
}
# Creates 2 private subnet each in different AZ's.
resource "aws_subnet" "PrivateSubnet1a" {
  vpc_id            = aws_vpc.EKS-VPC.id
  cidr_block        = var.Private-subnet1a-cidr
  availability_zone = "eu-central-1a"
  tags = {
    Name = "PrivateSubnet1a-EKS"
  }
}

resource "aws_subnet" "PrivateSubnet1b" {
  vpc_id            = aws_vpc.EKS-VPC.id
  cidr_block        = var.Private-subnet1b-cidr
  availability_zone = "eu-central-1b"
  tags = {
    Name = "PrivateSubnet1b-EKS"
  }
}
# Creates one public subnet in eu-central-1a
resource "aws_subnet" "PublicSubnet1a" {
  vpc_id                  = aws_vpc.EKS-VPC.id
  cidr_block              = var.Public-subnet1a-cidr
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.IGW]
  tags = {
    Name = "PublicSubnet1a-EKS"
  }
}
# Creates Route Table
resource "aws_route_table" "EKS-route-table" {
  vpc_id = aws_vpc.EKS-VPC.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "EKS-route-table"
  }
}
# Create Route Table association
resource "aws_route_table_association" "EKS-route-table-association" {
  subnet_id      = aws_subnet.PublicSubnet1a.id
  route_table_id = aws_route_table.EKS-route-table.id
}

# Create Network ACL and attach it to VPC.
resource "aws_network_acl" "EKSVPCNACL" {
  vpc_id = aws_vpc.EKS-VPC.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "EKSVPCNACL"
  }
}

# Create an Security Group.

resource "aws_security_group" "sg_22" {
  name   = "sg_22"
  vpc_id = aws_vpc.EKS-VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
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
    Environment = "EKS-SG-22"
  }
}
resource "aws_security_group" "sg_80" {
  name   = "sg_80"
  vpc_id = aws_vpc.EKS-VPC.id
  ingress {
    from_port   = 80
    to_port     = 80
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
    Environment = "EKS-SG-80"
  }
}

# Create EC2 instance

resource "aws_instance" "webinstance1a" {
  ami                    = "ami-0502e817a62226e03"
  instance_type          = "t2.micro"
  availability_zone      = "eu-central-1a"
  subnet_id              = aws_subnet.PublicSubnet1a.id
  vpc_security_group_ids = [aws_security_group.sg_80.id, aws_security_group.sg_22.id]
  key_name               = "EKS-KP"
  tags = {
    Name        = "Stepping-Stone for EKS"
    Environment = "Test"
  }
  volume_tags = {
    Name        = "Stepping-Stone for EKS"
    Environment = "Test"
  }
}

# Create ECR Repository
resource "aws_ecr_repository" "krypton" {
  name                 = "ramiz-krypton"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
