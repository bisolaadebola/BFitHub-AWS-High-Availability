#!/bin/bash
set -e

# ============================================
# BFitHub - Jump Server User Data Script
# Project Owner: Bisola Adebola
# Platform: AWS EC2 / Ubuntu Linux
# ============================================

# Set server hostname
sudo hostnamectl set-hostname Jumper-Server-01

# Update operating system packages
sudo apt update -y
sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    nfs-common \
    stunnel4 \
    git \
    binutils

# Create directory for EFS mount
sudo mkdir -p /home/ubuntu/webserver

# ============================================
# Amazon EFS Configuration
# ============================================

# Replace <EFS-DNS-NAME> with the EFS DNS endpoint
# Example:
# fs-xxxxxxxx.efs.us-east-1.amazonaws.com

EFS_DNS="<EFS-DNS-NAME>"

# Add EFS mount configuration to /etc/fstab
echo "${EFS_DNS}:/ /home/ubuntu/webserver nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" \
| sudo tee -a /etc/fstab

# Mount EFS
sudo mount -a

# Verify mounted file systems
df -h

echo "Jump Server configuration completed successfully."