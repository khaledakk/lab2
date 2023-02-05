terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "f38ade84-0cba-45e3-b13f-79b651df8cfb"
  tenant_id       = "fc6a7f9a-6765-40b5-8d95-cc55cae4b685"
  client_id       = "6513c2df-5eb5-480d-8d1b-54dc315ee113"
  client_secret   = "M~B8Q~IWLLgSrm0H-JRgLMTd3LWcDCCg4CSa_axo"

}
