#!/bin/sh

rm nginx-hosts

terraform plan
terraform apply

ansible-playbook site.yml
