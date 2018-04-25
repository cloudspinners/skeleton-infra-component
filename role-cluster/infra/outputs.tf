output "ecs_cluster_id" {
  value = "${module.ecs_cluster.cluster_id}"
}

output "ecs_cluster_log_group" {
  value = "${module.ecs_cluster.log_group}"
}

output "ecs_cluster_instance_role_arn" {
  value = "${module.ecs_cluster.instance_role_arn}"
}

output "ecs_service_role_arn" {
  value = "${module.ecs_cluster.service_role_arn}"
}

output "vpc_id" {
  value = "${module.base_network.vpc_id}"
}

output "public_subnet_ids" {
  value = "${module.base_network.public_subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.base_network.private_subnet_ids}"
}

output "public_route_table_id" {
  value = "${module.base_network.public_route_table_id}"
}

output "private_route_table_id" {
  value = "${module.base_network.private_route_table_id}"
}

output "nat_public_ip" {
  value = "${module.base_network.nat_public_ip}"
}