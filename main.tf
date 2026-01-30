provider "aws"{}

resource "aws_vpc" "dev_vpc"{
    cidr_block = var.cidr_blocks[1].cidr_blocks
    tags = {
        Name: var.cidr_blocks[0].name
    }
}

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = var.cidr_blocks[2].cidr_blocks
  availability_zone = var.availability_zone
  tags = {
        Name: var.cidr_blocks[0].name
    }
}

data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev_subnet_2" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = var.cidr_blocks[0].cidr_blocks
  availability_zone = var.availability_zone
  tags = {
        Name: var.cidr_blocks[0].name
    }
}


