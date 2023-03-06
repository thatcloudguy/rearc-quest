resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.name}.${var.root_domain}"
  type    = "A"
  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}
data "aws_route53_zone" "selected" {
  name         = var.root_domain
}
# SSL Cert creation
resource "aws_acm_certificate" "quest_certificate" {
  domain_name       = "${var.name}.${var.root_domain}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
# create validation record for cert
resource "aws_route53_record" "quest_cert_dns" {
  for_each = {
    for dvo in aws_acm_certificate.quest_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id = data.aws_route53_zone.selected.zone_id
}
# # Get cert arn
# data "aws_acm_certificate" "quest" {
#   domain   = "${var.name}.${var.root_domain}"
# }

# Validate cert
resource "aws_acm_certificate_validation" "quest_cert_validate" {
  certificate_arn = aws_acm_certificate.quest_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.quest_cert_dns : record.fqdn]
}