#!/bin/bash
set -e

# ============================================
# BFitHub - Web Server User Data Script
# Project Owner: Bisola Adebola
# Platform: AWS EC2 / Ubuntu Linux
# ============================================

# Change hostname
sudo hostnamectl set-hostname "WebServer-$(hostname -I | awk '{print $1}')"

# Update server
sudo apt update -y
sudo apt upgrade -y

# Install Nginx
sudo apt install -y nginx

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Remove default Nginx web content
sudo rm -rf /var/www/html/*

# Install EFS/NFS dependencies
sudo apt install -y nfs-common stunnel4 git binutils

# ============================================
# Amazon EFS Configuration
# ============================================

# Replace with your EFS DNS endpoint when deploying.
EFS_DNS="<EFS-DNS-NAME>"

# Add EFS mount to /etc/fstab
echo "${EFS_DNS}:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" \
| sudo tee -a /etc/fstab > /dev/null

# Mount EFS
sudo mount -a

# Give Nginx ownership of the web directory
sudo chown -R www-data:www-data /var/www/html

# ============================================
# Datadog Agent Installation
# ============================================

#
# Supply DD_API_KEY securely at deployment time,
# for example through AWS Systems Manager Parameter Store,
# AWS Secrets Manager, or another secure secret-management method.

export DD_API_KEY="${DD_API_KEY:-<DATADOG_API_KEY>}"
export DD_SITE="uk1.datadoghq.com"

# Install Datadog Agent
bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"

echo "BFitHub web server configuration completed successfully."