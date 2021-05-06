variable "env_name" {
  default     = "IaaS-Azure"
  description = "Environment Name"
}

# variable "resource_group_name" {
#   default     = "${var.env_name}-RG"
#   description = "The name of the resource group"
# }

variable "resource_group_location" {
  default     = "West US"
  description = "The location of the resource group"
}

variable "network_address_pefix" {
  default     = "10.10."
  description = "Network prefix for net and subnets"
}
