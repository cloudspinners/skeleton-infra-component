resource "aws_elb" "nginx_load_balancer" {
  subnets = ["${split(",", data.terraform_remote_state.cluster.public_subnet_ids)}"]

  security_groups = [
    "${aws_security_group.private_elb_security_group.id}"
  ]

  listener {
    instance_port = "${var.http_port}"
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = "${var.ssh_port}"
    instance_protocol = "tcp"
    lb_port = "${var.ssh_port}"
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:${var.http_port}"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 60

  tags {
    Name = "elb-nginx-${var.component}-${var.deployment_identifier}-${var.estate}"
    Estate = "${var.estate}"
    Component = "${var.component}"
    Service = "nginx"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}

resource "aws_security_group" "private_elb_security_group" {
  name = "private-elb-nginx-${var.component}-${var.deployment_identifier}-${var.estate}"
  vpc_id = "${data.terraform_remote_state.cluster.vpc_id}"
  description = "nginx-${var.component}-elb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
      "${var.private_network_cidr}"
    ]
  }

  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = [
      "${data.terraform_remote_state.cluster.nat_public_ip}/32",
      "${var.private_network_cidr}"
    ]
  }

  egress {
    from_port = 1
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${var.private_network_cidr}"
    ]
  }
}
