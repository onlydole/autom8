provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# SSH Security Group - Port 22
resource "aws_security_group" "allow_ssh" {
  description = "Allow all SSH traffic"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# HTTP Security Group - Port 80
resource "aws_security_group" "allow_http" {
  description = "Allow all HTTP traffic"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Webserver - 01
resource "aws_instance" "webserver-01" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.allow_http.name}","${aws_security_group.allow_ssh.name}"]
  tags {
    ApplicationType = "nginx"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.webserver-01.public_ip} >> nginx-hosts"
  }
}

# Webserver - 02
resource "aws_instance" "webserver-02" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.allow_http.name}","${aws_security_group.allow_ssh.name}"]
  tags {
    ApplicationType = "nginx"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.webserver-02.public_ip} >> nginx-hosts"
  }
}

# Webserver Load Balancer
resource "aws_elb" "load-balancer" {
  availability_zones = ["${aws_instance.webserver-01.availability_zone}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:80/"
    interval = 5
  }

  instances = ["${aws_instance.webserver-01.id}","${aws_instance.webserver-02.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.allow_http.id}"]
}

# Outputs for configuration management step

output "webserver_01_ip" {
    value = "${aws_instance.webserver-01.public_ip}"
}

output "webserver_02_ip" {
    value = "${aws_instance.webserver-02.public_ip}"
}

output "webserver_elb_ip" {
    value = "${aws_elb.load-balancer.dns_name}"
}
