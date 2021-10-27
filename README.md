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

This project is covering Infrastructure as Code (IaaS) and Configuration Managment concepts.

### Getting Started
1. Clone this repository:  
    To clone this repository use command:
* *git clone <repo_URL>*  
  
    in your working directory.

2. Create your infrastructure as code  
    For this project it is first important to create and deploy a policy definition to deny the creation of resources that do not have tags. Next step is to add a Packer template (server.json) that contains a template for creating a server image. For this project a Linux Ubuntu 18.04-LTS image is created. After the image is created, next step is to create a Terraform template. Two files are used to write Terraform configuration, main.tf, where all declarations for necessary resources are defined and variables.tf, where variables are defined. 

3. For a detailed instructions how to use this code, you should install all required Dependencies and apply a commands refered in a Instructions chapter. If you follow a described steps, you should be able to build your own infrastructure.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1. **Clone this repository** to your own working directory -  
- locate yourself to a working directory by typing a command:  **cd <working_directory>** 

    When located in a working directory type:

* **git clone <repo_URL>**

to clone a repository to your local working_directory. If all source code is avaiable

2. **Deploy a policy** - to deploy a policy a appropriate JSON file should be created. Azure Policy is used to enforce organizational standards and compliance, manage costs and to ensure secure architecture. There are two way to create a policy definition, using a template .json file or specifying policy definition in a command entered inside of a command line interface. To create a policy definition use following commands:  
* **az policy definition create --name <policy_name> --rules <path_to_policy_definition_file>** 

* **az policy assignment create --policy <policy_name>**

To verify that new policy has been deployed use following command:  
* **az policy assignment list**

    For the purpouse of this project, a policy that ensures all indexed resources have tags is created. If that condition is not fulfilled, creation of a specific resource without a tag should be forbiden.  

3. Create an server image using Packer template:
**server.json** template file contains Packer configuration that is used to generate an server image. In this file you should provide your Azure subscription_id that can be found under Subscriptions tab on Azure portal. In this case, this variable is exported as a environment variable. Also, a os type, image publisher, sku, virtual machine size, location and resource group are defined in a Packer template. This values are configurabile and if we want to change them, changes should be done inside of a server.json file. A simple web application is provided within a provisioners block.  
When a Packer template is created, you can use following command to build a server image:  
* **packer build <path_to_server_json_file>**

    After the command is executed, server image will be created in a specified ressource group.

4. Create an Terraform template to build and deploy infrastructure:  
    In main.tf file, a code needed for the infrastructure setup is located. Firstly, it is important to specify resource group. A resource group with a exactly same name must be created in a Azure portal. Next steps are to create a appropriate virtual networks and subnets associated with a created resource group.
    After that, a security group with several security rules is defined. Created security rules are used to deny outbound internet connection between internet and virtual machines and to allow outbound and inbound internet access between virtual machines or to allow a access from load balancer to virtual machines. Moreover, a network interfaces are created along with public IP addresses. To provide high availability by distributing incoming traffic amoung virtual machines, a Loadbalancer is created with a backend address pool and address pool association for the network interface and loadbalancer. To create a virtual machines, azurerm_linux_virtual_machine is used. Using a source_image_id parameter, a server image created in a previous step using Packer is linked. Finally, managed disks and availability sets are created. All variables are declared and defined inside of variables.tf file. First variable is a prefix variable, that enables us to create a arbitrarily names for resources that will be created. Besides that, it is possible to change a server location, packer image name and number of resources. Each of the variables has a default value and number_of_resources variable has a limitation that allows only values between two and five to be used. A value for each of the attributes can be modified in variables.tf file, when default attribute value is changed. To deploy a terraform configuration, firstly we need to create a resource group named "<prefix>_resource_group", where prefix variable is defined inside of variables.tf file.
    This group needs to be imported so that it can be referenced while deploying. To do so, use a following command:  
* **terraform import azurerm_resource_group.main /subscriptions/<subscription_id>/resourceGroups/<resource_group_name>**
    When a Terraform configuration is created, we run:  
* **terraform plan -out <filename>**  
    command that creates an execution plan. That execution plan is saved on a specified path when -out flag is used.  
    After a execution plan is created, we use a command:  
* **terraform apply**  
    to deploy a code.



### Output

Several outputs are 

