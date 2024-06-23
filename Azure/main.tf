# Configure the Azure Provider
provider "azure" {
  version = "2.34.0"
  subscription_id = "your_subscription_id"
  client_id      = "your_client_id"
  client_secret = "your_client_secret"
  tenant_id      = "your_tenant_id"
}

# Create a resource group
resource "azure_resource_group" "example" {
  name     = "example-resource-group"
  location = "West US 2"
}

# Create a virtual network
resource "azure_virtual_network" "example" {
  name                = "example-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azure_resource_group.example.location
  resource_group_name = azure_resource_group.example.name
}

# Create a subnet
resource "azure_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name = azure_resource_group.example.name
  virtual_network_name = azure_virtual_network.example.name
  address_prefix       = "10.0.1.0/24"
}

# Create a public IP address
resource "azure_public_ip" "example" {
  name                = "example-public-ip"
  location            = azure_resource_group.example.location
  resource_group_name = azure_resource_group.example.name
  allocation_method = "Dynamic"
}

# Create a network interface
resource "azure_network_interface" "example" {
  name                = "example-network-interface"
  location            = azure_resource_group.example.location
  resource_group_name = azure_resource_group.example.name

  ip_configuration {
    name                          = "example-ip-configuration"
    subnet_id                     = (link unavailable)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = (link unavailable)
  }
}

# Create a virtual machine
resource "azure_virtual_machine" "example" {
  name                  = "example-virtual-machine"
  location            = azure_resource_group.example.location
  resource_group_name = azure_resource_group.example.name
  network_interface_ids = [(link unavailable)]

  vm_size = "Standard_DS2_v2"

  # This will delete the VM on destroy
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Install and configure Apache
resource "null_resource" "example" {
  depends_on = [azure_virtual_machine.example]

  connection {
    type        = "ssh"
    host        = azure_public_ip.example.ip_address
    user        = "azureuser"
    password    = "P@ssw0rd!"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]
  }
}