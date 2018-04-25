
data "aws_availability_zones" "all" {}

module "base_network" {
  source = "infrablocks/base-networking/aws"
  version = "0.2.0-rc.2"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  vpc_cidr = "${var.private_network_cidr}"
  region = "${var.region}"
  availability_zones = "${join(",", data.aws_availability_zones.all.names)}"

  private_zone_id = "${aws_route53_zone.private_zone.zone_id}"
  include_lifecycle_events = "no"
}
