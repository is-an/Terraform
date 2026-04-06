output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.demo_web.id
}

output "public_ip" {
  description = "퍼블릭 IP 주소"
  value       = aws_instance.demo_web.public_ip
}

output "instance_state" {
  description = "인스턴스 상태"
  value       = aws_instance.demo_web.instance_state
}

output "web_server_url" {
  description = "웹 서버 URL"
  value       = "http://${aws_instance.demo_web.public_ip}"
}