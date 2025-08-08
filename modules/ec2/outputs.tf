output "jump_box_id" {
  value = aws_instance.jump_box.id
}

output "jump_box_public_ip" {
  value = aws_instance.jump_box.public_ip
}

output "jump_box_private_ip" {
  value = aws_instance.jump_box.private_ip
}

output "k8s_node1_id" {
  value = aws_instance.k8s_node1.id
}

output "k8s_node1_private_ip" {
  value = aws_instance.k8s_node1.private_ip
}

output "k8s_node2_id" {
  value = aws_instance.k8s_node2.id
}

output "k8s_node2_private_ip" {
  value = aws_instance.k8s_node2.private_ip
}