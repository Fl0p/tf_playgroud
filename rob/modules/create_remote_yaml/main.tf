
resource "null_resource" "create_yaml" {
  connection {
    type        = "ssh"
    host        = var.remote_host_ip
    port        = var.remote_host_port
    user        = var.remote_username
    agent       = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.yaml_content}' > ${var.remote_file_path}"
    ]
  }
}
