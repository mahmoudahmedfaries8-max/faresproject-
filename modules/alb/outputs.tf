output "public_alb_dns" {
  value = aws_lb.public_alb.dns_name
}
