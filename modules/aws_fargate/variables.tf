variable "region" {
  default = "us-west-2"
}
variable "name" {
  default = "quest"
}
variable "env" {
  default = "dev"
}
variable "image" {
  default = "nodejs:latest"
}
variable "container_port" {
  default = 3000
}
variable "vpc_id" {
}
variable "public_subnets" {
}
variable "private_subnets" {
}
# root domain for app. result will be "name.root_domain"
variable "root_domain" {
}