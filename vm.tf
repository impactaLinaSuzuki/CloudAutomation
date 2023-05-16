resource "azurerm_public_ip" "ip-task-cloud" {
  name                = "ip-task-cloud"
  resource_group_name = azurerm_resource_group.rg-task-cloud.name
  location            = azurerm_resource_group.rg-task-cloud.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic-task-cloud" {
  name                = "nic-task-cloud"
  location            = azurerm_resource_group.rg-task-cloud.location
  resource_group_name = azurerm_resource_group.rg-task-cloud.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-task-cloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip-task-cloud.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-task-cloud" {
  name                            = "vm-task-cloud"
  resource_group_name             = azurerm_resource_group.rg-task-cloud.name
  location                        = azurerm_resource_group.rg-task-cloud.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "useradmin"
  admin_password                  = "Teste@123!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic-task-cloud.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg-task-cloud" {
  network_interface_id      = azurerm_network_interface.nic-task-cloud.id
  network_security_group_id = azurerm_network_security_group.nsg-task-cloud.id
}

resource "null_resource" "install-nginx" {
  connection {
    type = "ssh"
    host = azurerm_public_ip.ip-task-cloud.ip_address
    user = "useradmin"
    password = "Teste@123!"
  }

  provisioner "remote-exec"{
    inline = [ 
      "sudo apt update", 
      "sudo apt install -y nginx" 
      ]
  }

  depends_on = [ 
    azurerm_linux_virtual_machine.vm-task-cloud
   ]
}