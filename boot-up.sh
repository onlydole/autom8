#!/bin/sh

rm nginx-hosts

terraform plan
terraform apply

sleep 60

ansible-playbook site.yml
