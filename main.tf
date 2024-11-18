provider "aws" {
  region = "us-east-1" # or any region you prefer
}

provider "time" {}

# EC2 Instance
resource "aws_instance" "benchmark" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.default.key_name

  # EBS volume configuration for 30 GB storage
  root_block_device {
    volume_size = 30
  }

  # Security group allowing HTTP, HTTPS, and SSH
  vpc_security_group_ids = [aws_security_group.initial_access_sg.id]

  # User data script for instance initialization
  user_data = <<-EOF
              #!/bin/bash
              for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done
              # Add Docker's official GPG key:
              apt-get update -y
              apt-get install -y ca-certificates curl
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc

              # Add the repository to Apt sources:
              echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y

              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              usermod -aG docker $USER
              newgrp docker

              # Start Docker service
              systemctl start docker
              systemctl enable docker

              # Create Docker network
              docker network create benchmark-net

              # Run Juice Shop container
              docker run --restart always -e "NODE_ENV=unsafe" -d --name juice-shop --network benchmark-net -p 3000:3000 bkimminich/juice-shop@sha256:5aef8464395d101d984d255166b079a52a573fba900450612f8cf3da2ad3a2dd

              # Run WebGoat container
              docker run --restart always -d --name webgoat --network benchmark-net -e TZ=America/Bogota webgoat/webgoat@sha256:01672eb9aeba60d042ae1131d6de683b98fa64e9da60fa5d3daad2642a6795dd

              # Clone and set up DVWS-Node
              git clone https://github.com/salzateatfluid/dvws-node.git
              cd dvws-node
              docker compose up -d

              # Set up crAPI using Docker Compose
              curl -o docker-compose.yml https://raw.githubusercontent.com/salzateatfluid/crAPI/refs/heads/develop/deploy/docker/docker-compose.yml
              docker compose -f docker-compose.yml --compatibility up -d

              # Run HTTPS portal
              docker run -d \
               --name https-portal \
               --network benchmark-net \
               -p 80:80 \
               -p 443:443 \
               -e DOMAINS='juiceshop.${var.domain_root} -> http://juice-shop:3000, webgoat.${var.domain_root} -> http://webgoat:8080, webwolf.${var.domain_root} -> http://webgoat:9090, dvws-node.${var.domain_root} -> http://dvws-node:80, crapi.${var.domain_root} -> http://crapi-web:80, crapi-mail.${var.domain_root} -> http://mailhog:8025' \
               -e STAGE=production \
               steveltn/https-portal
              EOF

  tags = {
    Name = "WebAppServer"
  }
}

# Initial security group for allowing HTTP, HTTPS, and SSH
resource "aws_security_group" "initial_access" {
  name        = "initial_access_sg"
  description = "Security group for initial access"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.initial_allowed_cidr_block # Allow SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.initial_allowed_cidr_block # Allow HTTP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.initial_allowed_cidr_block # Allow HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for allowing HTTP, HTTPS, and SSH
resource "aws_security_group" "allow_egress_ips" {
  name        = "allow_egress_ips"
  description = "Allow web traffic and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # Allow SSH
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = var.allowed_cidr_blocks_ipv6 # Allow SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # Allow HTTP
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = var.allowed_cidr_blocks_ipv6 # Allow HTTP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # Allow HTTPS
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = var.allowed_cidr_blocks_ipv6 # Allow HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
