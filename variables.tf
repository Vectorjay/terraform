variable "cidr_blocks" {
  description = "subnet cidr block"
  type = list (object({
    cidr_blocks = string
    name = string
  }))
}

variable "availability_zone" {
  description = "availability zone"
}