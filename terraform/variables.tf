variable "EKS-vpc-cidr" {
    default = "172.20.0.0/16"
}

variable "Private-subnet1a-cidr" {
    default = "172.20.32.0/19"
}

variable "Private-subnet1b-cidr" {
    default = "172.20.64.0/19"
}

variable "Public-subnet1a-cidr" {
    default = "172.20.4.0/22"
}
