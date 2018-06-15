variable "region" {}
variable "component" {}
variable "deployment_identifier" {}
variable "estate" {}
variable "version_number" {}

variable "cluster_name" {}

# variable "cluster_state_bucket_region" {}
# variable "cluster_state_bucket_name" {}
# variable "cluster_state_bucket_is_encrypted" {}
# variable "cluster_state_key" {}

variable "nginx_image_repository_name" {}

variable "http_port" {}
variable "ssh_port" {}
variable "private_network_cidr" {}

variable "nginx_desired_count" {}
