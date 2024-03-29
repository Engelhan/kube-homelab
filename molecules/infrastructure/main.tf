resource "ssh_resource" "install_k3s" {
  for_each = local.control_nodes
  host     = each.value.host
  user     = each.value.user
  password = each.value.password
  commands = [
    "sudo sed -i 's/DE/& cgroup_memory=1 cgroup_enable=memory/' /boot/firmware/cmdline.txt",
    "sudo curl -sfL ${local.k3s.download_url} | sudo sh -",
    "sudo reboot"
  ]
  #private_key = file(each.value.private_key)
  timeout = "10m"
}

# Note: Removed waiting for k3s server to be ready

resource "ssh_resource" "uninstall_k3s" {
  for_each    = { for server in var.control_nodes : server.host => server }
  host        = each.value.host
  when        = "destroy"
  user        = each.value.user
  commands    = ["sudo bash -c 'k3s-killall.sh; k3s-uninstall.sh;'"]
  password    = each.value.password
  #private_key = file(each.value.private_key)
}


data "remote_file" "kubeconfig" {
  for_each = local.control_nodes
  conn {
    host        = each.value.host
    user        = each.value.user
    password    = each.value.password
    sudo        = true
    #private_key = file(each.value.private_key)
  }

  path        = "/etc/rancher/k3s/k3s.yaml"
  depends_on  = [
    ssh_resource.install_k3s
  ]
}


output "kubeconfig" {
  sensitive = true
  value = { for kubeconfig in values(data.remote_file.kubeconfig)
  : kubeconfig.conn[0].host => replace(kubeconfig.content, "127.0.0.1", kubeconfig.conn[0].host) }
}

output "result" {
  value = try(jsondecode(ssh_resource.install_k3s["k3c01.local"].result), {})
}