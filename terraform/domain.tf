resource "aws_route53_zone" "sixit" {
  name = "sixitnews.click"
  
  tags = {
    Environment = "dev"
  }
}

##PROTON MAIL
resource "aws_route53_record" "frontend" {
zone_id = "${aws_route53_zone.sixit.zone_id}"
name = "frontend.sixitnews.click."
type = "A"
ttl = "60"
records = [aws_instance.frontend.public_ip]
}

resource "aws_route53_record" "bastion" {
zone_id = "${aws_route53_zone.sixit.zone_id}"
name = "bastion.sixitnews.click."
type = "A"
ttl = "60"
records = [aws_instance.bastion.public_ip]
}

resource "aws_route53_record" "protonmail_mx" {
  zone_id = aws_route53_zone.sixit.zone_id
  name = ""
  type = "MX"
  ttl = 1800

  records = [
    "10 mail.protonmail.ch.",
  ]
}

#Sender Policy

resource "aws_route53_record" "protonmail_txt" {
  zone_id = aws_route53_zone.sixit.zone_id
  name = ""
  type = "TXT"
  ttl = 1800

  records = [
    "protonmail-verification=<random_number>",
    "v=spf1 include:_spf.protonmail.ch mx ~all"
  ]
}



resource "aws_route53_record" "primary" {
  zone_id = "${aws_route53_zone.sixit.zone_id}"
  name    = "www"
  type    = "A"
  ttl     = "60"
  failover_routing_policy {
    type = "PRIMARY"
  }
  set_identifier = "primary"
  records        = [aws_instance.frontend.public_ip]
  health_check_id = "${aws_route53_health_check.primary.id}"
}


resource "aws_route53_record" "secondary" {
  zone_id = "${aws_route53_zone.sixit.zone_id}"
  name    = "www"
  type    = "A"
  ttl     = "60"
  failover_routing_policy {
    type = "SECONDARY"
  }
  set_identifier = "secondary"
  records        = [aws_instance.bastion.public_ip]
  health_check_id = "${aws_route53_health_check.secondary.id}"
}


resource "aws_route53_health_check" "primary" {
  fqdn              = "frontend.sixitnews.click"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "2"
  request_interval  = "30"

  tags = {
    Name = "route53-primary-health-check"
  }
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = "bastion.sixitnews.click"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "2"
  request_interval  = "30"

  tags = {
    Name = "route53-secondary-health-check"
  }
}