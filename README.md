# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Project overview: 
In this project a simple web Server was deployed on a Azure cloud. Project was done in four steps:
1. A policy that ensures all indexed resourcecs are tagged was created and deployed with the name "tagging-policy"

2. A Packer template that creates a server image that anyone can use is created. 

3. Terraform template is writen to create inftrastructure based on a policy and image that are created in a previous steps. 

4. Created infrastracture is deployed on a Azure.

When abovementioned steps are executed, a infrastracture, including Resource Group, Virtual network and a subnet on that virtual network, Network Security Group, Network Interface (nic), Public IP and Load Balancer (lb) with backend address pool and address pool association for nic and the lb are created. Also, configurable number of virtual machines (between two and five) is created with a image deployed using Packer along with managed disks for virtual machines. 

### Getting Started
1. Clone this repository:  
    To clone this repository use command:
    * *git clone <repo_URL>*  
  
    in your working directory.

2. Create your infrastructure as code  
    For this project it is first important to create and deploy a policy definition to deny the creation of resources that do not have tags. Next step is to add a Packer template (server.json) that contains a template for creating a server image. For this project a Linux Ubuntu 18.04-LTS image is created. After the image is created, next step is to create a Terraform template. Two files are used to write Terraform congiuration, main.tf, where 


3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
**Your words here**

### Output
**Your words here**

