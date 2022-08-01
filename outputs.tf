output "virtual_network" {
  value = {
    id   = azurerm_virtual_network.vnet.id
    name = azurerm_virtual_network.vnet.name
    subnets = {
      for k, subnet in var.subnets : k => {
        subnet : {
          subnet_id : azurerm_subnet.subnet[k].id
          address_prefixes : azurerm_subnet.subnet[k].address_prefixes
        }
        network_security_group_id : azurerm_network_security_group.nsg[k].id
        network_security_group_name : azurerm_network_security_group.nsg[k].name
      }
    }
  }
}

output "templateInvocationCount" {
  value = local.templateInvocationCount
}