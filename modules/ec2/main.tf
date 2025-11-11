# Key + helper resources
resource "random_id" "key_suffix" {
  byte_length = 4
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "auto_key" {
  key_name   = "auto-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.example.public_key_openssh
}

# Public Security Group
resource "aws_security_group" "public_sg" {
  name   = "public-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # If lab requires tighter security, change to your IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Security Group (allow HTTP from public_sg)
resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# User data scripts:
# - public: install nginx and serve a simple index page
# - private: install python3, create a tiny app and run it as systemd service

locals {
  public_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <html><body><h1>Public Proxy (nginx) - served by Terraform</h1></body></html>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  private_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3
    mkdir -p /home/ec2-user/app
    cat > /home/ec2-user/app/app.py <<'PY'
    from http.server import SimpleHTTPRequestHandler, HTTPServer
    import socket
    class Handler(SimpleHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b"<html><body><h1>Private Backend (Python HTTP)</h1></body></html>")
    httpd = HTTPServer(('0.0.0.0', 8080), Handler)
    httpd.serve_forever()
    PY

    cat > /etc/systemd/system/backend-app.service <<'SERVICE'
    [Unit]
    Description=Simple Python Backend App
    After=network.target

    [Service]
    Type=simple
    User=ec2-user
    ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable backend-app
    systemctl start backend-app
  EOF
}

# Public EC2 instances (these are the targets for ALB)
resource "aws_instance" "public_proxy" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = element(var.public_subnets, count.index)
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = aws_key_pair.auto_key.key_name
  associate_public_ip_address = true
  user_data                   = local.public_user_data

  tags = {
    Name = "public-proxy-${count.index}"
  }
}

# Private EC2 instances (run backend app on port 8080)
resource "aws_instance" "private_backend" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = element(var.private_subnets, count.index)
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  key_name                    = aws_key_pair.auto_key.key_name
  associate_public_ip_address = false
  user_data                   = local.private_user_data

  tags = {
    Name = "private-backend-${count.index}"
  }
}

