# Access bash env variables
variable "env_ak" {
  type = string
  sensitive = true
}

variable "env_sk" {
  type = string
  sensitive = true
}

# Define AWS provider
provider "aws" {
    access_key = var.env_ak
    secret_key = var.env_sk
    region = "us-west-2"
}


# Create the VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "${var.cidr_block_vpc}"
  tags = {
    Name = "app_vpc"
  }
}

# Create the Subnet
resource "aws_subnet" "app_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "${var.cidr_block_subnet}"
  availability_zone = "${var.availability_zone_subnet}"
  tags = {
    Name = "app_subnet"
  }
}

# Create the Security Group
resource "aws_security_group" "sec-group-lb" {
  name        = "sec-group-lb"
  vpc_id      = aws_vpc.app_vpc.id

  # Define inbound and outbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["13.48.192.221/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-lb"
  }
}


resource "aws_security_group" "sec-group-general" {
  name        = "sec-group-general"
  vpc_id      = aws_vpc.app_vpc.id

  # Define inbound and outbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.48.192.221/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block_subnet}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-general"
  }
}



# Create the Internet Gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app_igw"
  }
}

# Create a route table
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name = "app_route_table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "app_association" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route_table.id
}



# Create key-pair in pem format
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
    key_name   = "linux-key"
    public_key = tls_private_key.key.public_key_openssh

    provisioner "local-exec" {
        command = "echo '${tls_private_key.key.private_key_pem}' > linux-key.pem && chmod 400 linux-key.pem"
  }
}


# Create LB instances
resource "aws_instance" "lb_instance" {
    ami = "${var.ami_id}"
    subnet_id = aws_subnet.app_subnet.id
    for_each = "${var.lb_instance}"
    instance_type = "${var.instance_type}"
        vpc_security_group_ids = [aws_security_group.sec-group-lb.id, aws_security_group.sec-group-general.id]
        private_ip = "${each.value}"
        key_name = aws_key_pair.key_pair.id
        associate_public_ip_address = true
        tags = {
            Name = "${each.key}"
        }
}

# Create Non LB instances
resource "aws_instance" "non_lb_instance" {
    ami = "${var.ami_id}"
    subnet_id = aws_subnet.app_subnet.id
    for_each = "${var.non_lb_instance}"
    instance_type = "${var.instance_type}"
        vpc_security_group_ids = [aws_security_group.sec-group-general.id]
        private_ip = "${each.value}"
        key_name = aws_key_pair.key_pair.id
        associate_public_ip_address = true
        tags = {
            Name = "${each.key}"
        }
}
