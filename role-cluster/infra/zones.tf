
data "aws_vpc" "default" {
  default = true
}

data "aws_route53_zone" "parent_zone" {
  name = "${var.domain_name}."
}

resource "aws_route53_zone" "private_zone" {
  name = "${var.private_domain_name}"
  vpc_id = "${data.aws_vpc.default.id}"
  vpc_region = "${var.region}"
}

resource "aws_route53_record" "private_ns" {
  zone_id = "${aws_route53_zone.private_zone.zone_id}"
  name    = "${var.private_domain_name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.private_zone.name_servers.0}",
    "${aws_route53_zone.private_zone.name_servers.1}",
    "${aws_route53_zone.private_zone.name_servers.2}",
    "${aws_route53_zone.private_zone.name_servers.3}",
  ]
}
