resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "CloudDemo"
    Demo = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.availability_zones)
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet: ${element(var.availability_zones, count.index)}"
    Type = "Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.availability_zones)
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + length(var.availability_zones))
  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet: ${element(var.availability_zones, count.index)}"
    Type = "Private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name"  = "${var.region}-igw"
    "Owner" = "CloudDemo"
  }
}


resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.availability_zones)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.nat.*.id, count.index)

  tags = {
    "Name"  = "NAT: ${element(var.availability_zones, count.index)}"
    "Owner" = "CloudDemo"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.availability_zones)

  tags = {
    "Name" = "Private: ${element(var.availability_zones, count.index)}"
  }
}

resource "aws_route" "private_nat_gateway" {
  count                  = length(var.availability_zones)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}