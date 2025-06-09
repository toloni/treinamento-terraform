
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Sub-A"
    Tipo = "Public"
  }
}

resource "aws_subnet" "this_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Sub-B"
    Tipo = "Private"
  }
}

resource "aws_subnet" "this_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Sub-C"
    Tipo = "Public"
  }
}

resource "aws_subnet" "this_d" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Sub-D"
    Tipo = "Private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "VPC-1-IGW"
  }

  depends_on = [aws_vpc.this]
}

# Tabela de Roteamento Publica
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "VPC-1-RT-Public"
  }
}
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.this_c.id
  route_table_id = aws_route_table.public_rt.id
}

# Tabela de Roteamento Privada
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "VPC-1-RT-Private"
  }
}
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.this_b.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.this_d.id
  route_table_id = aws_route_table.private_rt.id
}

# Instancia EC2

resource "aws_security_group" "sg" {
  name        = "MY-SG-VPC"
  description = "Security group for web server"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-02457590d33d576c3"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.this.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]

  tags = {
    Name = "EC2-1A"
  }

  depends_on = [aws_route_table_association.public_assoc_1]
}



