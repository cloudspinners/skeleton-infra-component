
data "template_file" "nginx_task_image_definition" {
  template = "${file("${path.root}/container-definitions/nginx_container_task_definitions.tpl.json")}"

  vars {
    nginx-name = "nginx"
    nginx-image = "${data.template_file.nginx_image.rendered}"
    region = "${var.region}"
    log-group = "${data.terraform_remote_state.cluster.ecs_cluster_log_group}"
  }
}

data "aws_iam_policy_document" "nginx_assume_role_policy_contents" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "nginx_role" {
  name = "nginx-role-${var.component}-${var.deployment_identifier}-${var.estate}"
  assume_role_policy = "${data.aws_iam_policy_document.nginx_assume_role_policy_contents.json}"
}


module "ecs_service" {
  source = "infrablocks/ecs-service/aws"
  version = "~> 0.1.12"

  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.cluster.vpc_id}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  service_name = "nginx"
  service_port = "${var.http_port}"
  service_task_container_definitions = "${data.template_file.nginx_task_image_definition.rendered}"

  service_desired_count = "${var.nginx_desired_count}"
  service_deployment_minimum_healthy_percent = "50"
  service_deployment_maximum_percent = "200"

  service_elb_name = "${aws_elb.nginx_load_balancer.name}"
  service_role = "${aws_iam_role.nginx_role.arn}"

  ecs_cluster_id = "${data.terraform_remote_state.cluster.ecs_cluster_id}"
  ecs_cluster_service_role_arn = "${data.terraform_remote_state.cluster.ecs_service_role_arn}"
}
