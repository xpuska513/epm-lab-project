provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAIFYFZKVTAKXDDWBA"
  secret_key = "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"
}
# Allowing all trafic
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "jenkins" {
  ami = "ami-0b59bfac6be064b78"
  instance_type = "t2.micro"
  
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  key_name = "1"
  tags {
    Name = "terraform-jenkins",
    Ansible = "Jenkins"
  }
  #provisioner "local-exec" {
  #      command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ./deployer.pem -i '${aws_instance.jenkins_master.public_ip},' master.yml"
  #  }
}
resource "aws_instance" "application" {
  ami = "ami-0b59bfac6be064b78"
  instance_type = "t2.micro"
  
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  key_name = "1"
  tags {
    Name = "terraform-application",
    Ansible = "Nodes"
  }
}

output "application_ip" {
  value = "${aws_instance.application.public_ip}"
}

output "jenkins_ip" {
  value = "${aws_instance.jenkins.public_ip}"
}

output "application_private_ip" {
  value = "${aws_instance.application.private_ip}"
}
