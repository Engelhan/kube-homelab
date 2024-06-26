variable "control_nodes" {
  description = "machines which will run the control plane"
  type = list(object({
    host = string
    user = string
    #private_key = string
    password = string
  }))
  default = []
}

variable "k3s" {
  type = object({
    download_url = optional(string),
    version = optional(string),
  })
  default = {}
}