provider "aws" {
  region = "us-east-1"
  access_key =""
  secret_key = ""
}
# Main VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

# Public Subnet with Default Route to Internet Gateway
resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a:"

  tags = {
    Name = "Public Subnet-1"
  }
}

# Public Subnet with Default Route to Internet Gateway
resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "Public Subnet-2"
  }
}

# Private Subnet with Default Route to NAT Gateway
resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Private Subnet-1"
  }
}

# Private Subnet with Default Route to NAT Gateway
resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "Private Subnet-2"
  }
}

# Main Internal Gateway for VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "NAT Gateway EIP"
  }
}

# Main NAT Gateway for VPC
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public1.id

  tags = {
    Name = "Main NAT Gateway"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public-1" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public-2" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
  }
 
  tags = {
    Name = "Private Route Table"
  }
}


# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private-1" {
  subnet_id = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private-2" {
  subnet_id = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "sg" {
  name = "sg1"
  description = "sg1"
  vpc_id = aws_vpc.main.id

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "instance1" {
  ami =  "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public1.id
  associate_public_ip_address = true
  key_name = "terra-dev"

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }
}

resource "aws_instance" "instance2" {
  ami =  "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public2.id
  associate_public_ip_address = true
  key_name = "terra-dev"

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER02"
    Environment = "QA"
    OS = "UBUNTU"
    Managed = "IAC"
  }
}

resource "aws_instance" "instance3" {
  ami =  "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private1.id
  associate_public_ip_address = true
  key_name = "terra-dev"

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER03"
    Environment = "PROD"
    OS = "UBUNTU"
    Managed = "IAC"
  }
}

resource "aws_instance" "instance4" {
  ami =  "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private2.id
  associate_public_ip_address = true
  key_name = "terra-dev"

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER04"
    Environment = "practice"
    OS = "UBUNTU"
    Managed = "IAC"
  }

}






terraform plan --var-file="$(terraform workspace show).tfvars"

terraform -chdir=environments/dev destroy


