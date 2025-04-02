# Manage-EC2Instances.ps1

# Import AWS PowerShell module
Import-Module AWS.Tools.AutoScaling
Import-Module AWS.Tools.EC2

# Function to get AWS credentials and region
function Initialize-AWSConnection {
    param (
        [string]$ProfileName = "default",
        [string]$Region = "us-east-1"
    )
    
    try {
        Set-AWSCredential -ProfileName $ProfileName
        Set-DefaultAWSRegion -Region $Region
        Write-Host "AWS connection initialized successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error initializing AWS connection: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to list EC2 instances in the Auto Scaling Group
function Get-ASGInstances {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AutoScalingGroupName
    )
    
    try {
        # Get Auto Scaling Group details
        $asg = Get-ASAutoScalingGroup -AutoScalingGroupName $AutoScalingGroupName
        
        if ($null -eq $asg) {
            Write-Host "Auto Scaling Group '$AutoScalingGroupName' not found" -ForegroundColor Red
            return
        }

        # Get instance IDs from ASG
        $instanceIds = $asg.Instances.InstanceId

        if ($instanceIds.Count -eq 0) {
            Write-Host "No instances found in Auto Scaling Group '$AutoScalingGroupName'" -ForegroundColor Yellow
            return
        }

        # Get detailed instance information
        $instances = Get-EC2Instance -InstanceId $instanceIds
        
        # Display instance information
        Write-Host "`nInstances in Auto Scaling Group '$AutoScalingGroupName':" -ForegroundColor Cyan
        foreach ($instance in $instances.Instances) {
            Write-Host "`nInstance ID: $($instance.InstanceId)"
            Write-Host "State: $($instance.State.Name)"
            Write-Host "Instance Type: $($instance.InstanceType)"
            Write-Host "Launch Time: $($instance.LaunchTime)"
            Write-Host "Private IP: $($instance.PrivateIpAddress)"
            Write-Host "Public IP: $($instance.PublicIpAddress)"
            
            # Get instance tags
            $nameTag = $instance.Tags | Where-Object { $_.Key -eq "Name" }
            if ($nameTag) {
                Write-Host "Name Tag: $($nameTag.Value)"
            }
        }

        Write-Host "`nCurrent ASG Settings:" -ForegroundColor Cyan
        Write-Host "Desired Capacity: $($asg.DesiredCapacity)"
        Write-Host "Min Size: $($asg.MinSize)"
        Write-Host "Max Size: $($asg.MaxSize)"
    }
    catch {
        Write-Host "Error retrieving instances: $_" -ForegroundColor Red
    }
}

# Function to update Auto Scaling Group capacity
function Update-ASGCapacity {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AutoScalingGroupName,
        
        [Parameter(Mandatory=$true)]
        [int]$DesiredCapacity,
        
        [Parameter(Mandatory=$false)]
        [int]$MinSize,
        
        [Parameter(Mandatory=$false)]
        [int]$MaxSize
    )
    
    try {
        # Get current ASG settings
        $asg = Get-ASAutoScalingGroup -AutoScalingGroupName $AutoScalingGroupName
        
        if ($null -eq $asg) {
            Write-Host "Auto Scaling Group '$AutoScalingGroupName' not found" -ForegroundColor Red
            return
        }

        # Validate desired capacity against current min/max
        if ($MinSize -eq 0) { $MinSize = $asg.MinSize }
        if ($MaxSize -eq 0) { $MaxSize = $asg.MaxSize }

        if ($DesiredCapacity -lt $MinSize -or $DesiredCapacity -gt $MaxSize) {
            Write-Host "Desired capacity must be between Min Size ($MinSize) and Max Size ($MaxSize)" -ForegroundColor Red
            return
        }

        # Update ASG
        Update-ASAutoScalingGroup -AutoScalingGroupName $AutoScalingGroupName `
                                -DesiredCapacity $DesiredCapacity `
                                -MinSize $MinSize `
                                -MaxSize $MaxSize

        Write-Host "`nAuto Scaling Group updated successfully" -ForegroundColor Green
        Write-Host "New Desired Capacity: $DesiredCapacity"
        Write-Host "New Min Size: $MinSize"
        Write-Host "New Max Size: $MaxSize"
    }
    catch {
        Write-Host "Error updating Auto Scaling Group: $_" -ForegroundColor Red
    }
}

# Main script execution
function Main {
    # Initialize AWS connection
    Initialize-AWSConnection

    # Get stack name from user
    $stackName = Read-Host "Enter the CloudFormation stack name"
    
    # Get ASG name (assuming it follows the pattern in the template)
    $asgName = "$stackName-asg"

    while ($true) {
        Write-Host "`n=== EC2 Instance Management Menu ===" -ForegroundColor Cyan
        Write-Host "1. List current instances"
        Write-Host "2. Update instance count"
        Write-Host "3. Exit"
        
        $choice = Read-Host "`nEnter your choice (1-3)"
        
        switch ($choice) {
            "1" {
                Get-ASGInstances -AutoScalingGroupName $asgName
            }
            "2" {
                $desiredCapacity = Read-Host "Enter desired number of instances"
                if ($desiredCapacity -match '^\d+$') {
                    Update-ASGCapacity -AutoScalingGroupName $asgName -DesiredCapacity ([int]$desiredCapacity)
                }
                else {
                    Write-Host "Please enter a valid number" -ForegroundColor Red
                }
            }
            "3" {
                Write-Host "Exiting..." -ForegroundColor Yellow
                return
            }
            default {
                Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            }
        }
    }
}

# Run the script
Main
