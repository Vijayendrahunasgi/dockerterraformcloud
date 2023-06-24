resource "azurerm_network_interface" "dockerwp_nic" {
   name                = "acctnic"
   location            = azurerm_resource_group.dockerwp.location
   resource_group_name = azurerm_resource_group.dockerwp.name

   ip_configuration {
     name                          = "dockerwpConfiguration"
     subnet_id                     = azurerm_subnet.dockerwpsub.id
     private_ip_address_allocation = "dynamic"
	 public_ip_address_id          = azurerm_public_ip.dockerwppub.id
   }
 }

resource "azurerm_public_ip" "dockerwppub" {
   name                			= "pip"
   location                     = azurerm_resource_group.dockerwp.location
   resource_group_name          = azurerm_resource_group.dockerwp.name
   allocation_method            = "Dynamic"
   domain_name_label   			= "dockerwp"
 }

resource "azurerm_network_security_group" "dockerwp" {
   name                = "dockerwpSecurityGroup"
   location            = azurerm_resource_group.dockerwp.location
   resource_group_name = azurerm_resource_group.dockerwp.name
 }
 
resource "azurerm_network_security_rule" "docker_nsg" {
  name                        = "docker_nsg"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_ranges      = ["22"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dockerwp.name
  network_security_group_name = azurerm_network_security_group.dockerwp.name
}

resource "azurerm_network_security_rule" "docker_8080" {
  name                        = "docker_tomcat"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_ranges      = ["8080"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dockerwp.name
  network_security_group_name = azurerm_network_security_group.dockerwp.name
}

resource "azurerm_network_security_rule" "docker_1527" {
  name                        = "docker_mysql"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_ranges      = ["3306"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dockerwp.name
  network_security_group_name = azurerm_network_security_group.dockerwp.name
}

resource "azurerm_network_security_rule" "docker_80" {
  name                        = "docker_apache"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_ranges      = ["80"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.dockerwp.name
  network_security_group_name = azurerm_network_security_group.dockerwp.name
}


resource "azurerm_storage_account" "stor" {
  name                     = "dockerwpstor"
  location                 = azurerm_resource_group.dockerwp.location
  resource_group_name      = azurerm_resource_group.dockerwp.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "dockerwp-server"
  location              = azurerm_resource_group.dockerwp.location
  resource_group_name   = azurerm_resource_group.dockerwp.name
  vm_size               = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.dockerwp_nic.id]

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
    
  }

  storage_os_disk {
    name              = "dockerwp-server-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "dockerwp-server"
    admin_username = "vijay"
    admin_password = "Password123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  provisioner "remote-exec" {
	inline = [
	 "sudo apt-get update -y",
	 "cd /home/vijay/",
	 "sudo apt install git -y",
	 "sudo git clone https://github.com/vijaypranesh/dockerinstall.git",
	 "sudo chmod +x /home/vijay/dockerinstall/docker_install.sh",
	 "sudo /home/vijay/dockerinstall/docker_install.sh"
	]
	
	connection {
	  type	= "ssh"
	  host	= azurerm_public_ip.dockerwppub.fqdn
	  user	= "vijay" 
	  password = "Password1234!"
	}
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.stor.primary_blob_endpoint
  }
}
