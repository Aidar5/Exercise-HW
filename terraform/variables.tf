variable "instance_type" {
        default = "t2.micro"
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
