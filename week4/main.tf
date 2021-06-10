provider "azurerm" {
    features {}
}

variable "client_id" {}

variable "client_secret" {}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable resource_group_name {
    default = "aks-vnode-rg"
}

variable location {
    default = "South Central US"
}

resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "aks-vnode-vnet"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  address_space       = ["2.0.0.0/24"]
}

resource "azurerm_subnet" "example-nodepool" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.k8s.name
  address_prefixes     = ["2.0.0.0/25"]
  depends_on           = [azurerm_virtual_network.example]
}

resource "azurerm_subnet" "example-aci" {
  name                 = "aci"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.k8s.name
  address_prefixes     = ["2.0.0.248/29"]
  depends_on           = [azurerm_virtual_network.example]

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "virtualnodecluster"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = "k8s"
  kubernetes_version  = "1.18.14"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2s"
    type           = "AvailabilitySet"
    vnet_subnet_id = azurerm_subnet.example-nodepool.id
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled = false
    }
  }
}