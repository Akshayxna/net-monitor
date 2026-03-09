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

resource "aws_instance" "docker_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
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

resource "aws_security_group" "docker_sg" {
  name        = "allow_web_traffic_v2" # Changed name to avoid conflicts
  description = "Allow port 80"
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



output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.docker_instance.public_ip
}

output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.docker_instance.public_dns
}