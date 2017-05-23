provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

# Route53
resource "aws_route53_zone" "primary" {
  name    = "c2p4.com."
  comment = "HostedZone created by Route53 Registrar and Managed by Terraform"
}

resource "aws_route53_record" "gmail_txt" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${aws_route53_zone.primary.name}"
  type    = "TXT"
  ttl     = "3600"
  records = ["google-site-verification=MQDoIIVhr2gNZxnCv7zbNteU2zPOKZU9oSrCMAzZCWE"]
}

resource "aws_route53_record" "mx" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = ""
  type    = "MX"
  ttl     = "3600"
  records = ["1 aspmx.l.google.com", "5 alt1.aspmx.l.google.com", "5 alt2.aspmx.l.google.com",
              "10 alt3.aspmx.l.google.com", "10 alt4.aspmx.l.google.com"]
}
