<img width="1004" height="594" alt="image" src="https://github.com/user-attachments/assets/627f3949-3490-4c5f-bd8d-b38473d7d9a3" />



Secure Web App with Public Proxy + Private Backend on AWS (Terraform)
📌 Project Overview

This project deploys a secure, scalable web application architecture on AWS using Terraform, following a public-proxy and private-backend design pattern.

The architecture includes:

VPC with 2 public subnets and 2 private subnets

Nginx reverse proxy EC2 instances in the public subnets

Backend Web Application EC2 instances (Flask / Node.js / Apache) in private subnets

Public Application Load Balancer → routes external traffic to Proxy EC2

Internal Application Load Balancer → routes internal traffic to Backend EC2

NAT Gateway + Internet Gateway for controlled outbound internet

Terraform remote backend (S3 + DynamoDB)

New Terraform Workspace called dev

Custom terraform modules (not public registry)

Provisioners:

remote-exec → install proxy or apache

file → upload backend app files

local-exec → generate all-ips.txt



File Tree Overview
TERRAFORM PROJECT


├── modules/
│   ├── alb_target/   
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── ec2_backend/        
│   │   ├── scripts/        
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── ec2_proxy/          
│   │   ├── scripts/       
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── igw/      _        
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── load_balancer/      
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── nat_gateway/        
│  _  │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── Private_subnet/    
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── public_subnet/      
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── routing_tables/    
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── security_group/     
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── vpc/               
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   └── webapp/            
│   │   ├── app.py
│   └── └── requirements.txt
│
├── .gitignore             
├── .terraform.lock.hclMusic   
├── main.tf                 
├── variables.tf          
└── outputs.tf             


odule Responsibilities
🌍 Networking Foundation
vpc: Defines the foundational network boundary (10.0.0.0/16). Its outputs (like vpc_id) are used by almost every other module.
public_subnet & Private_subnet: These modules are called twice (once for each AZ) to create the four subnets. They depend on the vpc module.
igw: Creates the Internet Gateway to allow inbound/outbound internet traffic for the public subnets.
nat_gateway: Creates the NAT Gateway (in a public subnet) to allow outbound-only internet access for the private subnets (e.g., for software updates).
routing_tables: The "traffic controller." This module creates the public and private route tables and associates them with the correct subnets. This is what officially makes a subnet "public" (a route to the IGW) or "private" (a route to the NAT Gateway).

 Security
security_group: A highly reusable module. This module is called multiple times from the root main.tf to create the different firewalls for each tier:
Public ALB SG: Allows web traffic (80/443) from the internet.
Proxy SG: Allows traffic only from the Public ALB.
Internal ALB SG: Allows traffic only from the Proxy instances.
Backend SG: Allows traffic only from the Internal ALB.

Compute & Load Balancing
load_balancer: Provisions both the internet-facing (public) ALB and the internal ALB.
ec2_proxy: Deploys the reverse proxy instances into the public subnets.
ec2_backend: Deploys the core application (BE WS) instances into the private subnets, making them inaccessible from the internet.
alb_target: The glue that connects compute to the load balancers. This module is used to create target groups and register the EC2 instances from ec2_proxy and ec2_backend with their respective ALBs.




Getting Started
Prerequisites
Before you begin, ensure you have the following tools installed and configured:

Terraform (v1.0.0 or later)
AWS CLI
An AWS Account with configured credentials (e.g., via aws configure)
🔧 Deployment Steps
Clone the repository:

git clone 
cd aws-secure-webapp-terraform
Initialize Terraform: This downloads the necessary AWS provider plugins.

terraform init
Review the execution plan: This command shows you what resources Terraform will create, modify, or destroy.

terraform plan
Apply the configuration: This command will build the infrastructure in your AWS account.

terraform apply
Type yes when prompted to approve the plan.

After the apply is complete, Terraform will output any configured values, such as the public URL of the load balancer.

🧹 Clean Up
To avoid ongoing charges, you can destroy all the resources created by this project when you are finished.

terraform destroy


<img width="1838" height="741" alt="Terraform-ec2" src="https://github.com/user-attachments/assets/f5a3d732-3701-4359-a4bb-4bc64ed48f4c" />

<img width="1903" height="718" alt="Terraform-Tragetgroups" src="https://github.com/user-attachments/assets/e65eee70-4853-4ba1-bd47-305092996a12" />



<img width="1860" height="716" alt="Terraform-Loadbalancers" src="https://github.com/user-attachments/assets/21272960-8845-4f86-9d67-d84d01364417" />


<img width="1524" height="882" alt="Terraform-alb" src="https://github.com/user-attachments/assets/debd037a-68e7-4cd3-bcdf-d5f1155bc73b" />



<img width="1692" height="874" alt="Terraform-afterreload" src="https://github.com/user-attachments/assets/42cdad49-99f1-4691-b0df-f7495f902f63" />













