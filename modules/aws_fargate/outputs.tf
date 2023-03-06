output "repository_name" {
  description = "The URL of the repository."
  value = aws_ecr_repository.quest-ecr.name
}
output "cluster_name" {
    description = "The name of the ecs cluster created"
    value = aws_ecs_cluster.quest-cluster.name
}
output "service_name" {
    description = "The name of the ecs service created"
    value = aws_ecs_service.app.name
}
output "image_name" {
    description = "Update main variable with image once ecr is deployed"
    value = "${aws_ecr_repository.quest-ecr.repository_url}/${aws_ecr_repository.quest-ecr.name}:latest"
}
output "url" {
    description = "URL to visit to verify success"
    value = aws_route53_record.domain.name
}