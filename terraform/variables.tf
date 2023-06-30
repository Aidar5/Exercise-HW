variable "instance_type" {
        default = "t2.micro"
}

variable "cidr_block_vpc" {
        default = "192.168.0.0/24"
}

variable "cidr_block_subnet" {
        default = "192.168.0.0/25"
}

variable "availability_zone_subnet" {
        default = "us-west-2a"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0688ba7eeeeefe3cd"
}

variable "ip_lb" {
        default = "192.168.0.11"
}

variable "ip_web" {
        default = "192.168.0.12"
}

variable "ip_db" {
        default = "192.168.0.13"
}

variable "lb_instance" {
  type = map
  default = {
    "LB" = "192.168.0.11"
  }
}

variable "non_lb_instance" {
  type = map
  default = {
    "WEB" = "192.168.0.12"
    "DB" = "192.168.0.13"
  }
}
