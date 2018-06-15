data "aws_ecr_repository" "nginx_image_repository" {
  name = "ecr-repository"
}

data "template_file" "nginx_image" {
  template = "$${repository_url}:$${tag}"



  vars {

    tag = "${var.version_number}"
    repository_url = "${data.aws_ecr_repository.nginx_image_repository.repository_url}"
  }
}
