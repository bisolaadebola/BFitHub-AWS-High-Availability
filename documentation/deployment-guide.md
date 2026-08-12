# BFitHub – Highly Available Web Application on AWS

## Project Information

**Project Owner:** Bisola Adebola  
**Project Type:** Hands-on Cloud Infrastructure Deployment  
**Cloud Platform:** Amazon Web Services (AWS)  
**Operating System:** Ubuntu Linux  
**Application Domain:** `app.bfithub.store`  
**Project Focus:** High Availability, Scalability, Security, Shared Storage, Monitoring & Alerting

---

# Architecture Deployment Flow

The infrastructure was deployed in the following general order:

1. Create the VPC and network architecture.
2. Create public and private subnets.
3. Configure the Internet Gateway.
4. Configure route tables.
5. Create the NAT Gateway.
6. Configure Security Groups.
7. Create Amazon EFS.
8. Configure the Jump/Bastion Server.
9. Configure EC2 web servers.
10. Mount EFS to the web servers.
11. Configure the Application Load Balancer.
12. Configure the Auto Scaling Group.
13. Configure DNS.
14. Request and configure the SSL/TLS certificate.
15. Configure Datadog monitoring.
16. Configure Slack alerts.
17. Test application availability and infrastructure health.

---

# Phase 1 – Network Infrastructure

## 1. Create the VPC

A custom Amazon VPC was created to provide an isolated network environment for the application infrastructure.

**VPC CIDR:**

```text
192.168.0.0/16
```

The VPC provides the network foundation for the BFitHub infrastructure.

---

## 2. Create the Subnets

The architecture uses multiple subnets across Availability Zones.

The subnet design includes:

* 2 Public Subnets
* 2 Private Subnets

The public subnets are used for internet-facing resources such as the Application Load Balancer and NAT Gateway.

The private subnets are used for application servers that should not require direct inbound access from the internet.

---

## 3. Create and Attach the Internet Gateway

An Internet Gateway was created and attached to the VPC.

The Internet Gateway provides internet connectivity for resources located in the public subnets.

A route was added to the public route table:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

---

## 4. Configure Route Tables

Separate routing was configured for public and private resources.

### Public Route Table

The public route table routes internet-bound traffic through the Internet Gateway.

```text
0.0.0.0/0 → Internet Gateway
```

### Private Route Table

Private application servers do not route directly to the Internet Gateway.

Outbound internet traffic from private resources is routed through the NAT Gateway.

```text
0.0.0.0/0 → NAT Gateway
```

---

## 5. Configure the NAT Gateway

A NAT Gateway was deployed in a public subnet.

Its purpose is to allow resources in private subnets to initiate outbound internet connections without making those resources directly accessible from the internet.

This allows private EC2 instances to perform tasks such as:

* Downloading software packages.
* Installing updates.
* Communicating with external services.

---

# Phase 2 – Security

## 6. Configure Security Groups

Security Groups were created to control traffic between the different components of the architecture.

Rather than exposing all resources to the internet, access was restricted based on the role of each resource.

### Load Balancer Security Group

Allows incoming web traffic:

```text
HTTP  : TCP 80
HTTPS : TCP 443
```

### Web Server Security Group

Allows application traffic from the Application Load Balancer.

Administrative access should be restricted to trusted infrastructure such as the Jump Server rather than exposed broadly to the internet.

### EFS Security Group

Amazon EFS requires NFS traffic.

```text
NFS : TCP 2049
```

NFS access is restricted to the web servers that require access to the shared file system.

### Jump Server Security Group

SSH access is restricted as much as possible to trusted administrator IP addresses.

```text
SSH : TCP 22
```

---

# Phase 3 – Shared Storage

## 7. Create Amazon EFS

Amazon Elastic File System (EFS) was created to provide shared storage for the web servers.

EFS allows multiple EC2 instances to access the same website files.

This is important in an Auto Scaling environment because new EC2 instances can access the same application content instead of storing independent copies of the website.

---

## 8. Configure EFS Network Access

EFS mount targets were configured for the required Availability Zones.

The EFS Security Group allows:

```text
TCP 2049
```

from the web server Security Group.

---

# Phase 4 – Jump Server

## 9. Create the Jump/Bastion Server

A Jump Server was deployed to provide controlled administrative access to the infrastructure.

The server uses Ubuntu Linux.

Example hostname:

```text
Jumper-Server-01
```

The Jump Server provides a controlled path for managing servers that should not be directly exposed to the public internet.

---

## 10. Configure the Jump Server

The Jump Server configuration included:

```bash
sudo hostnamectl set-hostname Jumper-Server-01
sudo apt update -y
sudo apt upgrade -y
```

Required packages were installed:

```bash
sudo apt install -y nfs-common stunnel4 git binutils
```

A directory was created for the EFS mount:

```bash
mkdir -p /home/ubuntu/webserver
```

---

# Phase 5 – Configure EFS Mounting

## 11. Add EFS to `/etc/fstab`

The EFS file system was configured to mount automatically.

Example:

```text
<EFS-DNS-NAME>:/ /home/ubuntu/webserver nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0
```

> The actual EFS ID should be replaced with the appropriate file system endpoint for the environment.

The `_netdev` option helps ensure the operating system treats the mount as dependent on network availability.

---

## 12. Mount EFS

After updating `/etc/fstab`, the file system can be mounted using:

```bash
sudo mount -a
```

The mount can be verified using:

```bash
df -h
```

---

# Phase 6 – Web Server Configuration

## 13. Deploy Ubuntu Web Servers

Ubuntu EC2 instances were used as the application web servers.

The web servers were configured automatically using EC2 User Data and Bash scripting where appropriate.

Configuration tasks included:

* Updating the operating system.
* Installing required packages.
* Configuring the web server.
* Mounting Amazon EFS.
* Accessing the shared website files.
* Preparing the instance for load-balanced traffic.

The configuration script is stored in:

```text
scripts/web-server-user-data.sh
```

---

# Phase 7 – Application Load Balancer

## 14. Create the Application Load Balancer

An Application Load Balancer was deployed across the public-facing network.

Its purpose is to distribute incoming application requests across multiple web servers.

This removes dependency on a single EC2 instance.

---

## 15. Create the Target Group

A Target Group was configured for the web servers.

The load balancer uses health checks to determine whether instances are healthy enough to receive application traffic.

Only healthy targets should receive requests from the load balancer.

---

# Phase 8 – Auto Scaling

## 16. Create the Launch Configuration/Template

A reusable EC2 configuration was created for the application servers.

The configuration defines items such as:

* AMI
* Instance type
* Security Group
* User Data
* Other required EC2 settings

---

## 17. Create the Auto Scaling Group

An Auto Scaling Group was configured to manage the application EC2 instances.

The Auto Scaling Group integrates with the Application Load Balancer Target Group.

This allows new instances to automatically become part of the application infrastructure.

Auto Scaling improves:

* Availability
* Fault tolerance
* Scalability
* Recovery from unhealthy instances

---

# Phase 9 – HTTPS

## 18. Request the SSL/TLS Certificate

An SSL/TLS certificate was requested using AWS Certificate Manager.

The certificate is used to secure:

```text
app.bfithub.store
```

DNS validation was used to verify control of the domain.

---

## 19. Configure HTTPS Listener

The Application Load Balancer was configured with an HTTPS listener:

```text
HTTPS : TCP 443
```

The AWS Certificate Manager certificate was associated with the listener.

This enables encrypted communication between users and the application.

---

# Phase 10 – DNS

## 20. Configure the Application Domain

The application domain is:

```text
app.bfithub.store
```

DNS records were configured so the application domain resolves to the AWS load-balanced infrastructure.

DNS propagation was verified during deployment.

---

# Phase 11 – Monitoring

## 21. Configure Datadog

Datadog was integrated with the environment to provide infrastructure monitoring.

Monitoring provides visibility into areas such as:

* Server health
* Resource utilization
* Availability
* Infrastructure events
* Operational issues

---

# Phase 12 – Slack Alerting

## 22. Integrate Slack with Monitoring

Slack was configured as an alerting destination.

The monitoring workflow is:

```text
AWS Infrastructure
        ↓
     Datadog
        ↓
   Alert Triggered
        ↓
      Slack
        ↓
 Administrator
```

This enables faster visibility when infrastructure conditions require attention.

---

# Phase 13 – Testing

## 23. Verify Load Balancing

The application was accessed through the load balancer to confirm that traffic reached healthy web servers.

---

## 24. Verify EFS

The EFS mount was checked from the web servers.

Example:

```bash
df -h
```

Shared website files were verified to be accessible.

---

## 25. Verify Auto Scaling

The Auto Scaling Group was checked to confirm that the required EC2 capacity was running and registered with the Target Group.

---

## 26. Verify HTTPS

The application was accessed using:

```text
https://app.bfithub.store
```

The HTTPS connection was checked to verify that the SSL/TLS certificate was being presented correctly.

---

## 27. Verify Monitoring and Alerts

Datadog was checked to verify infrastructure monitoring.

Slack notifications were tested to confirm that alerts could reach the configured Slack destination.

---

# Final Architecture

The completed request flow can be summarized as:


                  🏗️ Architecture Flow


                         Internet
                            │
                            ▼
                      Route 53 DNS
                            │
                            ▼
                      HTTPS / SSL
                 AWS Certificate Manager
                            │
                            ▼
                Application Load Balancer
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
          EC2 Web        EC2 Web        EC2 Web
           Server         Server         Server
              │             │             │
              └─────────────┼─────────────┘
                            │
                            ▼
                       Amazon EFS
                    (Shared Storage)

                  Auto Scaling Group
                 manages EC2 instances
                   ↙       ↓       ↘
                 EC2      EC2      EC2

                 Monitoring & Alerting
                         │
                         ▼
                      Datadog
                         │
                         ▼
                       Slack
                  (Alert Notifications)
```
# Deployment Outcome

The completed infrastructure demonstrates the integration of networking, compute, storage, security, load balancing, scaling, DNS, HTTPS, monitoring, alerting, and Linux administration within a single AWS project.

The deployment was designed to reduce single points of failure while improving the application's scalability, operational visibility, and maintainability.

---

**Project Owner:** Bisola Adebola
**Project:** BFitHub – Highly Available AWS Infrastructure
**Application:** `app.bfithub.store`
