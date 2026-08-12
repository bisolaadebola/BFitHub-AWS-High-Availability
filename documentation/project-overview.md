# BFitHub – Highly Available AWS Infrastructure

## Project Overview

BFitHub is a hands-on cloud infrastructure project designed and deployed on Amazon Web Services (AWS) to demonstrate how a web application can be hosted using a highly available, scalable, secure, and monitored cloud architecture.

The project combines AWS infrastructure, Linux administration, networking, shared storage, load balancing, auto scaling, DNS, HTTPS, and monitoring to create an environment capable of supporting a production-style web application.

The application is available through:

**Domain:** `app.bfithub.store`

---

## Project Ownership

**Project Owner:** Bisola Adebola
**Project Type:** Hands-on Cloud Infrastructure Deployment
**Cloud Platform:** Amazon Web Services (AWS)
**Operating System:** Ubuntu Linux
**Project Focus:** High Availability, Scalability, Security, Monitoring, Alerting & Web Hosting

---

## Project Objectives

The main objectives of this project were to:

* Design a highly available AWS network architecture.
* Deploy web servers using Amazon EC2 and Ubuntu Linux.
* distribute application traffic using an Application Load Balancer.
* automatically adjust compute capacity using Amazon EC2 Auto Scaling.
* provide shared persistent website storage using Amazon EFS.
* securely administer private infrastructure through a Jump/Bastion Server.
* provide outbound internet connectivity for private resources using a NAT Gateway.
* secure network traffic using Security Groups.
* configure DNS and HTTPS for the application.
* implement infrastructure monitoring using Datadog.
* integrate Slack for infrastructure alerts and notifications.
* gain practical experience troubleshooting a multi-service AWS environment.

---

# Architecture Overview

The infrastructure was designed across multiple subnets to improve availability and security.

The architecture includes:

* Custom Amazon VPC
* Two public subnets
* Two private subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Application Load Balancer
* Amazon EC2
* Auto Scaling Group
* Amazon EFS
* Jump/Bastion Server
* Security Groups
* DNS configuration
* SSL/TLS certificate
* Datadog monitoring
* Slack alerting

The Application Load Balancer receives incoming application traffic and distributes requests across EC2 web servers.

The web servers use Amazon EFS to access shared website content, allowing multiple EC2 instances to serve the same application files.

Auto Scaling provides the ability to increase or decrease the number of EC2 instances based on application demand and configured scaling policies.

---

# AWS Services & Technologies Used

| Service / Technology      | Purpose                                                                  |
| ------------------------- | ------------------------------------------------------------------------ |
| Amazon VPC                | Provides an isolated network for the infrastructure                      |
| Public & Private Subnets  | Separates internet-facing and internal resources                         |
| Internet Gateway          | Provides internet connectivity to public resources                       |
| NAT Gateway               | Provides outbound internet connectivity for resources in private subnets |
| Route Tables              | Controls network traffic between subnets and gateways                    |
| Amazon EC2                | Hosts the Ubuntu web servers and Jump Server                             |
| Application Load Balancer | Distributes incoming application traffic                                 |
| EC2 Auto Scaling          | Maintains availability and adjusts compute capacity                      |
| Amazon EFS                | Provides shared persistent storage for web servers                       |
| Security Groups           | Provides instance and service-level network access control               |
| AWS Certificate Manager   | Provides the SSL/TLS certificate for HTTPS                               |
| DNS                       | Maps the application domain to the infrastructure                        |
| Ubuntu Linux              | Operating system used for EC2 instances                                  |
| Bash                      | Used for server configuration and automation                             |
| Datadog                   | Infrastructure monitoring and observability                              |
| Slack                     | Receives monitoring alerts and notifications                             |
| Git                       | Version control                                                          |
| GitHub                    | Project documentation and source control                                 |

---

# High Availability

High availability was one of the primary goals of the project.

Instead of relying on a single web server, the architecture uses multiple EC2 instances and an Application Load Balancer.

The load balancer distributes incoming requests across healthy instances.

Auto Scaling helps maintain the required number of instances and provides the ability to replace unhealthy instances or scale capacity when required.

Deploying resources across multiple Availability Zones reduces dependency on a single infrastructure location.

---

# Scalability

Amazon EC2 Auto Scaling was implemented to allow the infrastructure to respond to changes in application demand.

This architecture provides the foundation for automatically increasing compute capacity during higher demand and reducing unnecessary capacity when demand decreases.

This helps balance application performance, availability, and infrastructure cost.

---

# Shared & Persistent Storage

Amazon EFS was used to provide shared storage for the web servers.

The website files are stored on EFS and mounted to the EC2 web servers.

This means multiple web servers can access the same website content.

It also separates the application content from an individual EC2 instance, reducing dependency on the lifecycle of a single server.

---

# Security

Several security measures were incorporated into the architecture.

These include:

* Separating public and private resources using subnets.
* Using Security Groups to restrict network access.
* Using a Jump/Bastion Server for administrative access.
* Keeping application servers behind the Application Load Balancer.
* Using HTTPS to encrypt traffic between users and the application.
* Using controlled NFS access between EC2 instances and Amazon EFS.
* Avoiding direct public exposure of private application resources.

---

# Monitoring & Alerting

Datadog was integrated into the environment to provide infrastructure monitoring and visibility.

Monitoring allows server and application health to be observed so that potential problems can be identified quickly.

Slack was integrated with the monitoring environment to receive alerts and notifications.

The monitoring workflow can be represented as:

`AWS Infrastructure → Datadog → Slack Alert → Administrator`

This provides a more proactive approach to infrastructure operations rather than waiting for users to report problems.

---

# DNS & HTTPS

The application uses:

**`app.bfithub.store`**

DNS configuration connects the application domain to the AWS infrastructure.

An SSL/TLS certificate was configured to enable HTTPS, providing encrypted communication between users and the application.

This improves both application security and user trust.

---

# Skills Demonstrated

This project allowed me to practise and demonstrate skills in:

### Cloud Infrastructure

* AWS infrastructure deployment
* High availability architecture
* Scalability
* Load balancing
* Auto Scaling
* Shared storage

### Networking

* VPC design
* CIDR planning
* Public and private subnets
* Route tables
* Internet Gateway
* NAT Gateway
* Security Groups
* DNS

### Linux Administration

* Ubuntu server administration
* Package installation
* File and directory management
* NFS configuration
* EFS mounting
* `/etc/fstab` configuration
* Bash scripting
* Server troubleshooting

### Monitoring & Operations

* Datadog monitoring
* Slack alert integration
* Infrastructure health monitoring
* Troubleshooting

### Version Control & Documentation

* Git
* GitHub
* Markdown
* Technical documentation

---

# Business Value

The technical architecture was designed around several business requirements.

### Availability

Multiple web servers, load balancing, and Auto Scaling reduce dependency on a single EC2 instance and improve application availability.

### Scalability

Auto Scaling provides a mechanism for infrastructure capacity to respond to application demand.

### Reliability

Shared EFS storage allows multiple web servers to access consistent application content.

### Security

Network segmentation, Security Groups, HTTPS, and controlled administrative access reduce unnecessary exposure of infrastructure resources.

### Operational Visibility

Datadog monitoring provides visibility into infrastructure health.

### Faster Incident Response

Slack alerts allow infrastructure events to be surfaced quickly so that potential problems can be investigated sooner.

### Cost Awareness

Auto Scaling and cloud-based infrastructure provide opportunities to align resource usage with application demand rather than permanently provisioning unnecessary capacity.

---

# Key Challenges

During the project, I encountered and troubleshot several real-world infrastructure challenges, including:

* EFS and NFS connectivity.
* Security Group configuration.
* DNS propagation delays.
* SSL/TLS certificate validation.
* Application Load Balancer HTTPS configuration.
* EC2 user-data configuration.
* Shared website content across multiple servers.
* Monitoring and alert configuration.

These challenges provided valuable practical troubleshooting experience and reinforced the importance of understanding how individual AWS services interact within a larger architecture.

Detailed challenges and solutions are documented in:

`documentation/challenges-and-lessons-learned.md`

---

# Project Documentation

Additional project documentation is available in this repository:

* `documentation/deployment-guide.md` – Step-by-step infrastructure deployment.
* `documentation/challenges-and-lessons-learned.md` – Problems encountered, troubleshooting, solutions, and lessons learned.
* `scripts/` – Server configuration and automation scripts.
* `architecture/` – Infrastructure architecture diagram.
* `screenshots/` – Evidence of the infrastructure deployment.

---

# Future Improvements

Potential improvements to the architecture include:

* Infrastructure as Code using Terraform or AWS CloudFormation.
* CI/CD automation using GitHub Actions.
* More comprehensive CloudWatch and Datadog dashboards.
* AWS WAF for additional application-layer protection.
* Automated backup and recovery procedures.
* Centralized logging and log analysis.
* Automated security and configuration checks.

---

## Conclusion

The BFitHub Highly Available AWS Infrastructure project demonstrates the practical implementation of cloud networking, compute, shared storage, load balancing, scaling, security, monitoring, alerting, Linux administration, and web hosting.

More importantly, the project demonstrates how multiple AWS services can be integrated to address real business requirements such as **availability, scalability, security, reliability, operational visibility, and maintainability**.

---

**Project Owner:** Bisola Adebola
**Project:** BFitHub – Highly Available AWS Infrastructure
**Domain:** `app.bfithub.store`
