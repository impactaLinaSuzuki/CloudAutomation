resource "azurerm_virtual_network" "vnet-task-cloud" {
  name                = "vnet-task-cloud"
  resource_group_name = azurerm_resource_group.rg-task-cloud.name
  location            = azurerm_resource_group.rg-task-cloud.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub-task-cloud" {
  name                 = "sub-task-cloud"
  resource_group_name  = azurerm_resource_group.rg-task-cloud.name
  virtual_network_name = azurerm_virtual_network.vnet-task-cloud.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg-task-cloud" {
  name                = "nsg-task-cloud"
  location            = azurerm_resource_group.rg-task-cloud.location
  resource_group_name = azurerm_resource_group.rg-task-cloud.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

   security_rule {
    name                       = "Web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "Production"
  }
}

