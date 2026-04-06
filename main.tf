# ===========================================
# Terraform AWS EC2 Demo-Web 서버
# ===========================================
# 인스턴스명: Demo-Web
# 타입: t2.micro (프리 티어)
# 접근: SSH(22) + HTTP(80)
# 소프트웨어: Apache 웹 서버
# 리전: ap-northeast-2 (서울)

provider "aws" {
    region = "ap-northeast-2"
}

# 최신 Amazon Linux 2 AMI 동적 조회
data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners      = ["amazon"]
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name   = "state"
        values = ["available"]
    }
}

# SSH + HTTP 접근 보안 그룹
resource "aws_security_group" "demo_web_sg" {
    name        = "demo-web-sg"
    description = "Allow SSH and HTTP traffic"
    
    # SSH 포트 (22) 허용
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # HTTP 포트 (80) 허용
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # 모든 아웃바운드 트래픽 허용
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "Demo-Web Security Group"
    }
}

# EC2 인스턴스 생성 (Apache 자동 설치)
resource "aws_instance" "demo_web" {
    ami                    = data.aws_ami.amazon_linux_2.id
    instance_type          = "t2.micro"
    key_name               = "demo-terra-key"
    vpc_security_group_ids = [aws_security_group.demo_web_sg.id]
    
    # Apache 웹 서버 자동 설치 및 설정
    user_data = <<-EOF
        #!/bin/bash
        # 시스템 업데이트
        yum update -y
        
        # Apache 설치
        yum install -y httpd
        
        # 기본 웹 페이지 생성
        echo "<h1>Welcome to Demo-Web Server!</h1>" > /var/www/html/index.html
        echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
        echo "<p>Region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region)</p>" >> /var/www/html/index.html
        echo "<p>Created by Terraform</p>" >> /var/www/html/index.html
        
        # Apache 서비스 시작 및 부팅시 자동 시작
        systemctl start httpd
        systemctl enable httpd
    EOF
    
    tags = {
        Name = "Demo-Web"
        Type = "Web Server"
    }
}