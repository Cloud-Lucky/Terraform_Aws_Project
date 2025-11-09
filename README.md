# Terraform_Aws_Project
This project provisions a scalable infrastructure on AWS using Terraform. It automates the creation of compute, networking, and state-management resources required to deploy a highly available web application.
VPC Creates an isolated virtual network for hosting resources
Public Subnets Two public subnets across multi-AZ for high availability
EC2 Instances Two EC2 instances deployed in public subnets
Load Balancer Application Load Balancer to distribute traffic to EC2 instances
Route Table & Routes Routes traffic from the internet to the VPC resources
Security Groups Multiple SGs for instances and load balancer to control traffic flow
S3 Backend Stores terraform.tfstate securely
DynamoDB Table Used to lock the state file and prevent concurrent writes
![AWS Terraform Infra](https://github.com/user-attachments/assets/0be0f882-9411-4d05-8a52-9c2ff96ac53f)

![Server-2](https://github.com/user-attachments/assets/74d41c71-05b4-418f-8e7e-03ce66d189d2)
![Server-1](https://github.com/user-attachments/assets/027c5a04-0d0a-4abc-b145-ee2910234d5e)
![S3-terraform tfstate](https://github.com/user-attachments/assets/793f21b4-63e8-4492-879f-ab0329dd7523)
![LoadBalancer](https://github.com/user-attachments/assets/cb5639b2-ccbd-4c31-af58-57b347acf9e2)
![LB-Target](https://github.com/user-attachments/assets/d3477ac0-f5f3-4205-bc55-a00b98a52c79)
![Instances](https://github.com/user-attachments/assets/f83294de-0c61-43e3-9cb6-2875fc570925)
![DynamoDB-Lock](https://github.com/user-attachments/assets/50c73007-56c7-41ad-8217-01841038e6d3)
