
# Creating vpc

resource "aws_vpc" "docker_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Prod_vpc"
  }
}


# Internet Gateway

resource "aws_internet_gateway" "docker_gw" {
  vpc_id = aws_vpc.docker_vpc.id

  tags = {
    Name = "prod_gw"
  }
}

# Subnets

resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.docker_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.docker_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

}


# Route tables

resource "aws_route_table" "docker_rt" {
  vpc_id = aws_vpc.docker_vpc.id

  # Inline route for internet access (0.0.0.0/0)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker_gw.id
  }

  tags = {
    Name = "docker-route-table"
  }
}

# Route table Association 

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.docker_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.docker_rt.id
}



# Creating Load balancer 

resource "aws_lb" "docker_alb" {
  name               = "docker-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false


  tags = {
    Environment = "production"
  }
}


# Create Target group

 resource "aws_lb_target_group" "docker_tg" {
  name     = "docker-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.docker_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

 
# Listner

resource "aws_lb_listener" "docker_sg_listner" {
  load_balancer_arn = aws_lb.docker_alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker_tg.arn
  }
}

# Connect Ec2 to target group. 

resource "aws_lb_target_group_attachment" "docker_attachment" {
  target_group_arn = aws_lb_target_group.docker_tg.arn
  target_id        = aws_instance.docker_instance.id
  port             = 80
}


# ami for ec2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# creating ecs instance

resource "aws_instance" "docker_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id = aws_subnet.public_1.id
  user_data = file("user_data.sh")
  key_name   = "my-devops-key"
 

  tags = {
    Name = "Docker-instance"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-devops-key"
  public_key = file("~/.ssh/my_aws_key.pub") # The key lives here
}



# Create Security groups

resource "aws_security_group" "docker_sg" {
  name        = "allow_web_traffic_v2" # Changed name to avoid conflicts
  description = "Allow port 80"
  vpc_id = aws_vpc.docker_vpc.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web"
  }
}


# Outputs 

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.docker_alb.dns_name
}