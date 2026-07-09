rg = {
  rg1 = {
    name = "rg"
  }
}
vnet = {
  vnet1 = {
    name                = "vnet"
    address_space       = ["10.0.0.0/16"]
    resource_group_name = "rg"

  }
}
subnet = {
  sbnet1 = {
    name                 = "front-subnet"
    resource_group_name  = "rg"
    virtual_network_name = "vnet"
    address_prefixes     = ["10.0.1.0/24"]
  }
  sbnet2 = {
    name                 = "back-subnet"
    resource_group_name  = "rg"
    virtual_network_name = "vnet"
    address_prefixes     = ["10.0.2.0/24"]
  }
}

pip = {
  pip1 = {
    name                = "front-pip"
    resource_group_name = "rg"
    allocation_method   = "Static"

  }
  pip2 = {
    name                = "back-pip"
    resource_group_name = "rg"
    allocation_method   = "Static"

  }
}

nic = {
  nic1 = {
    name                          = "front-nic"
    resource_group_name           = "rg"
    ipconfig_name                 = "Internal"
    private_ip_address_allocation = "Dynamic"
    subnetkey                     = "sbnet1"
    pipkey                        = "pip1"
  }
  nic2 = {
    name                          = "back-nic"
    resource_group_name           = "rg"
    ipconfig_name                 = "Internal"
    private_ip_address_allocation = "Dynamic"
    subnetkey                     = "sbnet2"
    pipkey                        = "pip2"
  }
}

vm = {
  vm1 = {
    name                            = "front-vm"
    resource_group_name             = "rg"
    size                            = "Standard_D2s_v3"
    admin_username                  = "adminuser"
    admin_password                  = "Azure@12345"
    disable_password_authentication = false
    disk                            = "ReadWrite"
    storage_account_type            = "Standard_LRS"
    publisher                       = "Canonical"
    offer                           = "0001-com-ubuntu-server-jammy"
    sku                             = "22_04-lts"
    version                         = "latest"
    nickey                          = "nic1"
  }
  vm2 = {
    name                            = "back-vm"
    resource_group_name             = "rg"
    size                            = "Standard_D2s_v3"
    admin_username                  = "adminuser"
    admin_password                  = "Azure@12345"
    disable_password_authentication = false
    disk                            = "ReadWrite"
    storage_account_type            = "Standard_LRS"
    publisher                       = "Canonical"
    offer                           = "0001-com-ubuntu-server-jammy"
    sku                             = "22_04-lts"
    version                         = "latest"
    nickey                          = "nic2"
  }
}

nsg = {
  nsg1 = {
    name                       = "front-vm-nsg"
    resource_group_name        = "rg"
    rule-name                  = "front-nsg-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  nsg2 = {
    name                       = "back-vm-nsg"
    resource_group_name        = "rg"
    rule-name                  = "back-nsg-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

nsgassociation = {
  nsgass1 = {
    nickey = "nic1"
    nsgkey = "nsg1"
  }
  nsgass2 = {
    nickey = "nic2"
    nsgkey = "nsg2"
  }

}
