
locals {
  prefix         = "test"
  location       = "west us"
  enviromentname = "dev"
}

variable "rg" {}
variable "vnet" {}
variable "subnet" {}
variable "nic" {}
variable "pip" {}
variable "vm" {}
variable "nsg" {}
variable "nsgassociation" {
  
}