variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "ssh_key_name" {}
variable "ssh_key_path" {}
variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-2d39803a"
    us-west-2 = "ami-d732f0b7"
  }
}
