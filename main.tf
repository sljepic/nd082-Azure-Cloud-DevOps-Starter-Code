provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name                = "${var.prefix}_resource_group"
  location            = var.location 

  tags = {
    group_tag = "udacity_resource_group" 
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    network_tag = "udacity-network"
  }
}

resource "azurerm_subnet" "internal" {
  name                = "${var.prefix}-vnet"
  address_prefixes    = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.main.name  
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-SecurityGroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "DenyInternetToVirtualNetworkOutBound"
    priority                   = 100
    direction                  = "OutBound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork" 
  }

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"  
  }

  security_rule {
    name                       = "AllowVnetOutBound"
    priority                   = 120
    direction                  = "OutBound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork" 
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 130
    direction                  = "OutBound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyVMToInternetOutBound"
    priority                   = 140
    direction                  = "OutBound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Internet"  
  }

  tags = {
    network_group_tag = "udacity-nsg"
  }
}

resource "azurerm_network_interface" "main" {
  count = var.number_of_resources
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    network_group_tag = "udacity-nic"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-myPublicIp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags = {
    public_ip_tag = "udacity-ip"
  }

}

resource "azurerm_lb" "main" {
  name               = "${var.prefix}-LoadBalancer"
  location           = azurerm_resource_group.main.location
  resource_group_name= azurerm_resource_group.main.name

  frontend_ip_configuration  {
    name             = "PublicIpAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    loadbalancer_tag = "udacity-lb"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  count = var.number_of_resources
  name                = "${var.prefix}-address_pool-${count.index}"
  loadbalancer_id     = azurerm_lb.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.number_of_resources
  ip_configuration_name   = azurerm_network_interface.main[count.index].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.main[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.main[count.index].id
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    availability_set_tag = "udacity-aset"
  }
}

data "azurerm_resource_group" "image" {
  name                = "${var.prefix}_resource_group"
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_linux_virtual_machine" "example" {
  count = var.number_of_resources
  name                = "Virtual-machine-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  availability_set_id = azurerm_availability_set.main.id

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_id = data.azurerm_image.image.id

  tags = {
    vm_tag = "udacity-virtual_machine"
  }
}

resource "azurerm_managed_disk" "example" {
  count = var.number_of_resources
  name                 = "${var.prefix}-managed_disk-${count.index}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    managed_disk_tag = "udacity_managed_disk"
  }
}
