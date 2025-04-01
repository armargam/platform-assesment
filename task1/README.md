# Windows Web Server Infrastructure

## Overview
This CloudFormation template deploys a secure Windows web server infrastructure on AWS, including:
- Windows Server EC2 instance with IIS
- S3 bucket for application logging
- Security group with HTTPS and RDP access
- IAM roles and policies for secure access

## Prerequisites
- AWS Account
- AWS CLI installed and configured (for CLI deployment)
- Existing VPC and Subnet
- EC2 Key Pair
- Appropriate AWS permissions to create resources

## Quick Start

### Option 1: AWS Management Console
1. Navigate to AWS CloudFormation console
2. Click "Create stack" and choose "With new resources"
3. Upload the WebServer.yaml template
4. Fill in the required parameters:
   - VPC ID
   - Subnet ID
   - Key Pair name
   - Allowed RDP CIDR range
5. Review and create the stack

### Option 2: AWS CLI
```bash
aws cloudformation create-stack \
  --stack-name windows-webserver \
  --template-body file://WebServer.yaml \
  --parameters \
    ParameterKey=VpcId,ParameterValue=vpc-xxxx \
    ParameterKey=SubnetId,ParameterValue=subnet-xxxx \
    ParameterKey=KeyPairName,ParameterValue=your-key-pair \
    ParameterKey=AllowedRDPCidr,ParameterValue=x.x.x.x/x


