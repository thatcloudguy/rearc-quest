output "repository_name" {
  description = "The URL of the repository."
  value       = module.aws_fargate.repository_name
}
output "service_name" {
  description = "The ECS service that was created."
  value       = module.aws_fargate.service_name
}
output "cluster_name" {
  description = "The ECS Cluster that was created."
  value       = module.aws_fargate.cluster_name
}
output "region" {
  description = "The region our infrastructure was deployed."
  value       = var.region
}
output "image_name" {
  description = "The value you should set your image to in main.tf after initial deploy."
  value       = module.aws_fargate.image_name
}