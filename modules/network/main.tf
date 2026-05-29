# ------------------------------------------------------------------------------
# VPC & INTERNET GATEWAY
# ------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.environment}-vpc" })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.environment}-igw" })
}


# ------------------------------------------------------------------------------
# PUBLIC SUBNETS
# ------------------------------------------------------------------------------
resource "aws_subnet" "public-subnet" {
  for_each = toset(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr[each.key]
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${var.environment}-public-${each.key}" })
}

# Public Route Table (One is sufficient for all public subnets)
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(var.tags, { Name = "${var.environment}-public-rt" })
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_ass" {
  for_each = aws_subnet.public-subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-route-table.id
}


# ------------------------------------------------------------------------------
# NAT GATEWAYS (ONE PER AZ FOR HIGH AVAILABILITY)
# ------------------------------------------------------------------------------
resource "aws_eip" "nat_gateway_eip" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"

  tags = merge(var.tags, { Name = "${var.environment}-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = toset(var.availability_zones)

  allocation_id     = aws_eip.nat_gateway_eip[each.key].id
  subnet_id         = aws_subnet.public-subnet[each.key].id # Place NAT in the corresponding public subnet
  connectivity_type = "public"

  # Explicit dependency prevents race conditions during full environment builds
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = merge(var.tags, { Name = "${var.environment}-nat-${each.key}" })
}


# ------------------------------------------------------------------------------
# PRIVATE SUBNETS & ROUTING
# ------------------------------------------------------------------------------
resource "aws_subnet" "private-subnet" {
  for_each = toset(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[each.key]
  availability_zone = each.key

  tags = merge(var.tags, { Name = "${var.environment}-private-${each.key}" })
}

# Private Route Tables (Create one per AZ to route to that AZ's specific NAT Gateway)
resource "aws_route_table" "private-route-table" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = var.route_cidr
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }

  tags = merge(var.tags, { Name = "${var.environment}-private-rt-${each.key}" })
}

# Associate Private Subnets with their corresponding AZ's Private Route Table
resource "aws_route_table_association" "private_ass" {
  for_each = aws_subnet.private-subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-route-table[each.key].id
}