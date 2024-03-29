locals {
  k3s = coalesce({
    download_url = "https://get.k3s.io",
  }, var.k3s)

  control_nodes = {for server in var.control_nodes : server.host => server}
}
