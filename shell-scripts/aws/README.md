# Automating-AWS-Resource-Management-with-Shell-Script-

A shell script that automates the process of listing and filtering active AWS resources based on user-defined region and service. It utilizes the AWS CLI to fetch and display resource details such as IDs, names, and types.

## Features
- Allows users to specify the AWS region and service name (e.g., EC2, Lambda, S3).
- Uses AWS CLI to query for active resources in the specified region and service.
- Outputs a list of resource IDs, names, and types in a readable format.
- Can be easily customized to support additional AWS services.

## Supported AWS Services
- **EC2**: List active EC2 instances.
- **S3**: List S3 buckets.
- **Lambda**: List Lambda functions.

## Prerequisites
Before running the script, ensure you have the following:
- **AWS CLI** installed and configured with valid AWS credentials.
- Access to AWS resources in the specified region and service.

### Install AWS CLI (if not already installed)
Follow these instructions to install and configure AWS CLI on your machine:
- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Once installed, configure AWS CLI with your credentials:
```bash
aws configure

Installation
Clone the repository
Clone or download this repository to your local machine:
git clone https://github.com/yourusername/aws-resource-tracker.git


Make the shell script executable
Navigate to the project directory and make the script executable:
cd aws-resource-tracker
chmod +x resource-tracker.sh



Usage
1. Run the script:
./resource-tracker.sh

2. Enter the AWS region when prompted (e.g., us-west-1).
3. Enter the AWS service name when prompted (e.g., ec2, s3, or lambda).
Example interaction:
Enter AWS Region: us-west-1
Enter AWS Service Name: ec2


Adding Support for More AWS Services

To extend the script to support additional AWS services:

Add an elif condition for the new service in the script.
Use the appropriate AWS CLI command to fetch the list of resources for that service.
Format the output to match the expected structure.

Troubleshooting

If the AWS CLI is not installed or not configured, you may see errors when running the script. Ensure that the AWS CLI is installed and that your credentials are set up.


To configure AWS CLI, run:
aws configure

If the script doesn't display any resources, ensure that there are active resources in the selected region and service.
