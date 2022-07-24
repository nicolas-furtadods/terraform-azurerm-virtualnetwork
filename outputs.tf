output "virtual_network" {
    value = {
        id = azurerm_virtual_network.vnet.id
        name = azurerm_virtual_network.vnet.name
        subnets = azurerm_subnet.subnet[*]
    }
}