data "template_file" "cluster_instance_user_data_template" {
  template = "${file("${path.root}/scripts/user-data.tpl")}"
}

module "ecs_cluster" {
  source = "infrablocks/ecs-cluster/aws"
  version = "0.2.7-rc.2"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  subnet_ids = "${module.base_network.private_subnet_ids}"
  allowed_cidrs = ["${var.private_network_cidr}"]

  cluster_instance_ssh_public_key_path = "${var.cluster_instance_ssh_public_key_path}"
  cluster_instance_type = "${var.cluster_instance_type}"

  cluster_minimum_size = 1
  cluster_maximum_size = 2
  cluster_desired_capacity = 1

  cluster_instance_user_data_template = "${data.template_file.cluster_instance_user_data_template.rendered}"
  cluster_instance_iam_policy_contents = "${file("${path.root}/policies/cluster-instance-policy.json")}"

  cluster_instance_root_block_device_size = 100
  cluster_instance_docker_block_device_size = 30

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"
  cluster_name = "${var.cluster_name}"
}
