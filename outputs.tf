output "Virtual_Machine_IP" {
  value       = azurerm_public_ip.IaaS_PublicIP.ip_address
  description = "Virtual Machine IP Address"
}