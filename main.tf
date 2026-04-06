provider "aws"{}

resource "aws_vpc" "myapp_vpc"{
    cidr_block = var.vpc_cidr_block
    enable_dns_support   = true   # ✅ enables DNS resolution
    enable_dns_hostnames = true   # ✅ enables public DNS hostnames
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.env-prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw"{
    vpc_id = aws_vpc.myapp_vpc.id

    tags = {
        Name = "${var.env-prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb"{
    default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = [var.image_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-key" {
    key_name = "ec2-key"
    public_key = file(var.public_key_location)
}


resource "aws_instance" "demo" {
  ami           = data.aws_ami.latest-ubuntu.id
  count         = length(var.instance_names)
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  # user_data = file("nginx_setup.sh")

  # root_block_device {
  #   volume_size = 8

  #   tags = {
  #     Name        = "${var.instance_names[count.index]}"
  #     Environment = var.instance_names[count.index]
  #   }
  # }

  tags = {
    Name = "${var.instance_names[count.index]}"
  }

}

resource "null_resource" "Configure_server"{
  # This command will run after the instance is created, it will use Ansible to deploy Docker on the instance. Make sure to have Ansible installed and configured on your local machine.
  provisioner "local-exec" {
    working_dir = "../Ansible"
    command = "ansible-playbook --inventory ${aws_instance.demo[0].public_ip}, --private-key ${var.ssh_key_private} --user ubuntu deploy-node.yaml"
  }
}

