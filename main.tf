resource "aws_instance" "example" {
  ami           = "ami-019715e0d74f695be"   # Amazon Linux 2 AMI (example)
  instance_type = "t3.micro"

  tags = {
    Name = "MyFirstInstance"
  }
}

