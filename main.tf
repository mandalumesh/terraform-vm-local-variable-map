

resource "azurerm_resource_group" "rg" {
  for_each = var.rg
  name     = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  location = local.location
}
resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rg]
  for_each            = var.vnet
  name                = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  resource_group_name = "${local.prefix}-${local.enviromentname}-${each.value.resource_group_name}"
  location            = local.location
  address_space       = each.value.address_space

}

resource "azurerm_subnet" "sbnet" {
  depends_on           = [azurerm_virtual_network.vnet, azurerm_resource_group.rg]
  for_each             = var.subnet
  name                 = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  virtual_network_name = "${local.prefix}-${local.enviromentname}-${each.value.virtual_network_name}"
  resource_group_name  = "${local.prefix}-${local.enviromentname}-${each.value.resource_group_name}"
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_public_ip" "pip" {
  depends_on          = [azurerm_subnet.sbnet, azurerm_resource_group.rg]
  for_each            = var.pip
  name                = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  resource_group_name = "${local.prefix}-${local.enviromentname}-${each.value.resource_group_name}"
  location            = local.location
  allocation_method   = each.value.allocation_method

}

resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_public_ip.pip, azurerm_resource_group.rg]
  for_each            = var.nic
  name                = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  location            = local.location
  resource_group_name = "${local.prefix}-${local.enviromentname}-${each.value.resource_group_name}"

  ip_configuration {
    name                          = each.value.ipconfig_name
    subnet_id                     = azurerm_subnet.sbnet[each.value.subnetkey].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.pip[each.value.pipkey].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  depends_on                      = [azurerm_network_interface.nic, azurerm_resource_group.rg]
  for_each                        = var.vm
  name                            = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  resource_group_name             = "${local.prefix}-${local.enviromentname}-${each.value.resource_group_name}"
  location                        = local.location
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = each.value.disable_password_authentication
  network_interface_ids = [
    azurerm_network_interface.nic[each.value.nickey].id
  ]


  os_disk {
    caching              = each.value.disk
    storage_account_type = each.value.storage_account_type
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
}

resource "azurerm_network_security_group" "nsg" {
    depends_on = [ azurerm_linux_virtual_machine.vm, azurerm_resource_group.rg ]
    for_each = var.nsg
  name                = "${local.prefix}-${local.enviromentname}-${each.value.name}"
  location            = local.location
  resource_group_name = "${local.prefix}-${local.enviromentname}-${each.value.resource_group_name}"

  security_rule {
    name                       = each.value.rule-name
    priority                   = each.value.priority
    direction                  = each.value.direction
    access                     = each.value.access
    protocol                   = each.value.protocol
    source_port_range          = each.value.source_port_range
    destination_port_range     = each.value.destination_port_range
    source_address_prefix      = each.value.source_port_range
    destination_address_prefix = each.value.destination_address_prefix
  }
}

resource "azurerm_network_interface_security_group_association" "nsgassociation" {
    depends_on = [ azurerm_network_security_group.nsg, azurerm_network_interface.nic ]
    for_each = var.nsgassociation
  network_interface_id      = azurerm_network_interface.nic[each.value.nickey].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsgkey].id
}