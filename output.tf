output "public_ips" {
  value = aws_instance.demo[*].public_ip
}