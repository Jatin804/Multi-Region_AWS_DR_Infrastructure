# All netwoking resources are defined 
# VPC
resource "aws_vpc" "main" {
  cidr_block = var.aws_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-vpc"
    }
  )
}


# Public Subnets
resource "aws_subnet" "public-subnet" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-public-subnet-${count.index + 1}"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private-subnet" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-private-subnet-${count.index + 1}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-internet-gateway"
    }
  )
}

# elastic ip for nat gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-nat-gateway-eip"
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.public-subnet[0].id
  connectivity_type = "public"

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-nat-gateway"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-public-route-table"
    }
  )
}

# Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-private-route-table"
    }
  )
}

# Associating Public subnet to public route table 
resource "aws_route_table_association" "public_ass"{
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

# Associating Private subnet to private route table
resource "aws_route_table_association" "private_ass" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}