# EC2 Instance Management Script

## Overview
This PowerShell script provides a simple interface to manage EC2 instances within an Auto Scaling Group (ASG) created by a CloudFormation stack. It allows users to list instances and modify the number of running instances through ASG capacity management.

## Features
- List all EC2 instances in an Auto Scaling Group
- Display detailed instance information (ID, state, IP addresses, etc.)
- Show current Auto Scaling Group settings
- Modify instance count by updating ASG capacity
- Interactive menu-driven interface
- Error handling and input validation

## Prerequisites

### Required Software
- PowerShell 5.1 or later
- AWS Tools for PowerShell
  ```powershell
  Install-Module -Name AWS.Tools.AutoScaling
  Install-Module -Name AWS.Tools.EC2
