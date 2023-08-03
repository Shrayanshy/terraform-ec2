terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-3"
}

data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

resource "aws_iam_policy" "policy" {
  name        = "demopolicy12354"
  description = "My test policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
    ]
}
EOT
}

resource "aws_iam_role" "role" {
  name = "demorole12ka4"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "demoprofile1234567888"
  role = aws_iam_role.role.name
}

resource "aws_instance" "coldcoffee" {
  ami           = "ami-0df896ee24c051d42"
  instance_type = "t2.micro"
  key_name = "fdec"
iam_instance_profile = aws_iam_instance_profile.profile.name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data = <<EOF
  #!/bin/bash
BUCKET=artifactory-fdecb2
sudo dnf install java-11-amazon-corretto -y
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.91/bin/apache-tomcat-8.5.91.zip
sudo unzip apache-tomcat-8.5.91.zip
sudo mv apache-tomcat-8.5.91 /mnt/tomcat
KEY=`aws s3 ls $BUCKET --recursive | sort | tail -n 1 | awk '{print $4}'`
aws s3 cp s3://$BUCKET/$KEY /mnt/tomcat/webapps/
sudo chmod 0755 /mnt/tomcat/bin/*
sudo ./bin/catalina.sh start
EOF


  tags = {
    Name = "demotomcat1245"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "demoallow_tls12345"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mySG12345"
  }
}
