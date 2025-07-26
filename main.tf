provider "aws" {
  region = "eu-west-2"
  
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "198.162.0.0/16"

    tags = {
      Name = "provisioners_vpc"
    }
  
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "provisioners_igw"
    }
  
}

resource "aws_route_table" "my_rt" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

    tags = {
      Name = "provisioners_rt"
    }
  
}

resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "198.162.1.0/24"
    availability_zone = "eu-west-2a"    


    tags = {
      Name = "Pub_provisioners_subnet"
    }
  
}

resource "aws_route_table_association" "my_rt_assosiation" {
    subnet_id = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.my_rt.id
  
}

resource "aws_security_group" "my_sg" {

    name        = "provisioners_sg"
    description = "Allow SSH inbound traffic"    

    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  
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

    tags = {
      Name = "provisioners_sg"
    }
}

resource "aws_key_pair" "my_key_pair" {
  key_name  = "provisioners_key"
  public_key = file("~/.ssh/id_rsa.pub")   
}

resource "aws_instance" "my_instance" {
  ami           = "ami-044415bb13eee2391" # Example AMI, replace with a valid one
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]  

   associate_public_ip_address = true

  tags = {
    Name = "provisioners_instance"
  }

   connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
 }

    provisioner "file" {
        source      = "app.py"
        destination = "/home/ubuntu/app.py"

}

provisioner "local-exec" {
  command = "echo EC2 instance created at ${self.public_ip} > instance_info.txt"
}

 provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo apt install -y python3-flask",
      "nohup sudo python3 app.py > app.log 2>&1 &",
  ]
 }
}



