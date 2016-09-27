# AUTOM8 - A Taylor Dolezal Project

## Background

This project was created as a deep dive into using Hashicorp's Terraform to instantiate AWS instances and infrastructure, and to use Ansible as a configuration management solution to provision the created EC2 instances and then deploy a simple HTML page.

I chose Terraform and CircleCI mainly because I have not used them before and I wanted to see what the draw was behind both of these tools. After getting more acclimated with both of these solutions, I can see more of a place for them in my daily tasks and will most certainly be using them more. Terraform can be used across multiple cloud vendors and has a great selection of modules and plugins and also is able to output graphs that detail out the infrastructure. I'm excited to delve deeper into this community and create great applications and infrastructure as I learn more.

I structured the Terraform process to focus on AWS instantiation and light security measures for the web hosting application, though security is definitely one area that can be strengthened in subsequent passes.

The CircleCI configuration was quite easy, all things considered. I was surprised with how little I had to do to get this running in the state that I wanted my project to have. I did find that I needed to put in a delay to allow the EC2 instances to boot up before I could provision them over SSH with Ansible, but I'm sure that in future versions of Terraform, that I might be able to use a callback-type setup.  

Lastly, the Ansible step of the project was very straightforward (having used this tool for quite some time) and I was able to create a dynamic inventory that gets generated from Terraform that Ansible is then able to use for the final provisioning steps. In future passes, I may look at using the Ansible `ec2.py` dynamic inventory script and tags to create more of a clean inventory.

The sum up this whole procedure, this project:

1. Audits the syntax and overall validity of the Terraform configuration by running the `terraform plan` command. This step served me well as my automated infrastructure testing mechanism

2. Creates all the AWS infrastructure by running `terraform apply`

3. Runs the Ansible `site.yml` playbook to install nginx and deploy the `index.html` file on the Ubuntu 14.04 EC2 instance.

The load balancer serves as a good health check mechanism to make sure that all instances are properly deployed and configured and if the build process within CircleCI fails at any point, then I get an email alert to indicate that something has happened that requires my attention.

## Usage Instructions

You must have the latest versions of [Terraform](https://www.terraform.io/intro/getting-started/install.html) and [Ansible](http://docs.ansible.com/ansible/intro_installation.html) installed to run these scripts. You must also set up a CircleCI account to leverage the CI/CD steps that I have created as well.

### Account Credentials

The only step that is not automated currently is when you create AWS keypairs. For this project, it is recommended that you create a keypair named `terraform`.

You will also need to make sure that you have an IAM account that is able to spin up and down all of the infrastructure detailed out in the `init.tf` file.

### CircleCI

To set up CircleCI to work with this application, you will need to add your AWS SSH key hostname as "terraform" in the "SSH Permissions" sub-menu, inside of the "Project Settings" menu within the CircleCI interface.

You will also need to add the following environment variables in the CircleCI "Environment Variables" section of the site:

* `TF_VAR_access_key`=ACCESS_KEY_FROM_AWS
* `TF_VAR_secret_key`=SECRET_KEY_FROM_AWS
* `TF_VAR_ssh_key_name`=id_terraform
* `TF_VAR_ssh_key_path`=~/.ssh/id_terraform

### Local Testing

To test this locally, you will need to have all the software, credentials, and CircleCI (optional) steps set up properly.

You will also need to have the following environment variables set either by exporting them out or by using a Terraform `*.tfvars` file.

* export `TF_VAR_access_key`=ACCESS_KEY_FROM_AWS
* export `TF_VAR_secret_key`=SECRET_KEY_FROM_AWS
* export `TF_VAR_ssh_key_name`=id_terraform
* export `TF_VAR_ssh_key_path`=~/.ssh/id_terraform

To spin up your instances and test this application, you can run `./boot-up.sh` or to spin down the instances, you can run `./spin-down.sh` to remove all created instances.

### Postmortem

Overall, this project went quite smoothly and did involve a good amount of studying up on Terraform, then CircleCI, and only a few slight consultations of Ansible's documentation were made as well.

I was surprised to find how easy it was to use Terraform and keep thinking of new use cases for this tool that would make for more audit-worthy, reliable, and transparent projects. I did find myself wishing that there was a bit more documentation on Terraform on my specific use cases, but I was ultimately able to find all the pieces and parts that I needed. I liked all the collaboration features that Terraform had as well, especially the `terraform plan` command which, in essence, showed a `diff` of all the infrastructure changes that will be made when you run `terraform apply` which isn't good just for testing, but also for making sure only the changes you wanted are made.

For CircleCI, their documentation and steps to implement were very straightforward. I spent only about 20 minutes total on this step of my project before I was up and running the way I wanted to be.

I'd say that this is a good bare-bones type of production environment, though ultimately I'd want to spend more time adding in SSL integration, stronger security groups, and HTTP/2 as my final touches.

I'd also like to vet a few other CI/CD platforms to investigate which ones I like the most and to see which might be better fits for certain jobs too.

This was a very eventful and fun deep dive - I am already finding myself looking forward to the next time I do this.
