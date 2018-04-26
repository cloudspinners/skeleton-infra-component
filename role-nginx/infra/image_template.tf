data "template_file" "nginx_service_image" {
  template = "$${repository_url}:$${tag}"

  vars {
    repository_url = "${data.terraform_remote_state.nginx_image_repository.repository_url}"
    tag = "${var.version_number}"
  }
}
