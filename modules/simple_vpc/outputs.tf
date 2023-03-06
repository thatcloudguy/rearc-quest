output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc_example_simple-vpc.public_subnets
}
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_example_simple-vpc.vpc_id
}