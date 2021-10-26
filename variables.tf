variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "udacity"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}
 
variable "password" {
  description = "VM password"
  default = "123456789"
}

variable "packer_image_name" {
  description = "Packer image name"
  default = "ProjectPackerImage"
}

variable "number_of_resources" {
  description = "Number of resources that will be created"
  type = number
  default = 2

  validation {
    condition = var.number_of_resources <= 5 && var.number_of_resources >= 2
    error_message = "Number of resources must be between 2 and 5."
  } 
}