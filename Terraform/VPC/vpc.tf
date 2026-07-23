resource "aws_vpc" "vpc-1" {

  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

}

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.vpc-1
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc-1
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zonep
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpc-1.id

}

resource "aws_eip" "eip" {

  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

}

resource "aws_nat_gateway" "nat_gw" {

  allocation_id = aws_eip.eip.id

  subnet_id = aws_subnet.public.id

  depends_on = [
    aws_internet_gateway.igw
  ]
}


resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.vpc-1.id

}

resource "aws_route" "publicr" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.igw.id

}

resource "aws_route_table" "privatetb" {

  vpc_id = aws_vpc.vpc-1.id

}

resource "aws_route" "name" {

  route_table_id = aws_route_table.privatetb.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_nat_gateway.nat_gw.id

}

resource "aws_route_table_association" "private_tba" {

  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.privatetb

}

resource "aws_route_table_association" "public_rta" {

  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
