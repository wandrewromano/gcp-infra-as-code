variable "name_prefix" {
  description = "Prefix applied to all resource names, e.g. \"dev\" or \"staging\"."
  type        = string
}

variable "region" {
  description = "Region for the subnet and provider default."
  type        = string
}

variable "zone" {
  description = "Zone for the VM."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for this instance's subnet. Must not overlap other instances of this module."
  type        = string
}

variable "machine_type" {
  description = "Compute Engine machine type."
  type        = string
  default     = "e2-micro"
}
