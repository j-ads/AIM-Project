output "frontend_ip" {
  value       = aws_instance.frontend.public_ip
  description = "The public address of bastion host"
}

output "backenda_ip" {
  value       = aws_instance.backend-a.private_ip
  description = "The public address of bastion host"
}

output "backendb_ip" {
  value       = aws_instance.backend-b.private_ip
  description = "The public address of bastion host"
}

output "bastion_public_address" {
  value       = aws_instance.bastion.public_ip
  description = "The public address of bastion host"
}

output "lb_dns" {
  value       = aws_lb.lb.dns_name
  description = "The DNS name of the latest news api Load Balancer"
}

output "website_address" {
  value       = "http://www.sixitnews.click"
  description = "The public DNS of the news website"
}

output "dbpass" {
  value       = random_password.password.result
  sensitive   = true
  description = "Password for DB"
}

output "name_server"{
  value=aws_route53_zone.sixit.name_servers
}
