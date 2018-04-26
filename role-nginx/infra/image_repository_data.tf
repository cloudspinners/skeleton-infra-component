data "terraform_remote_state" "nginx_image_repository" {
  backend = "s3"

  config {
    region = "${var.nginx_image_repository_state_bucket_region}"
    bucket = "${var.nginx_image_repository_state_bucket_name}"
    encrypt = "${var.nginx_image_repository_state_bucket_is_encrypted}"
    key = "${var.nginx_image_repository_state_key}"
  }
}
