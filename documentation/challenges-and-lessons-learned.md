# BFitHub – Challenges & Lessons Learned

## Introduction

Building the BFitHub Highly Available AWS Infrastructure project involved more than deploying AWS resources. I encountered several configuration, networking, storage, DNS, HTTPS, and monitoring challenges that required troubleshooting and a deeper understanding of how AWS services interact.

This document highlights some of the key challenges I encountered, how I approached them, and the lessons I learned.

---

# 1. Amazon EFS Connectivity

## Challenge

One of the challenges was configuring Amazon EFS so that my EC2 instances could successfully access the shared file system.

Creating the EFS file system alone was not enough. The EC2 instances also needed network connectivity and permission to communicate with EFS using NFS.

## Troubleshooting

I reviewed:

* EFS mount targets
* Availability Zones
* Security Groups
* NFS connectivity
* Mount configuration
* `/etc/fstab`

EFS requires NFS traffic on:

```text
TCP 2049
```

I configured the EFS Security Group to allow NFS traffic from the Security Group associated with the web servers.

## Lesson Learned

Cloud connectivity depends on several components working together.

When a service cannot communicate with another service, I learned to check:

**Network → Routing → Security Group → Port → Service configuration**

rather than troubleshooting only the application itself.

---

# 2. Persisting the EFS Mount

## Challenge

Mounting EFS manually works for the current session, but I needed the file system to remain available after an EC2 instance reboot.

## Solution

I configured the EFS mount in:

```text
/etc/fstab
```

and used the `_netdev` option so Linux recognizes that the mount depends on network availability.

I then tested the configuration using:

```bash
sudo mount -a
```

and verified the mounted storage using:

```bash
df -h
```

## Lesson Learned

A configuration that works manually is not necessarily production-ready.

Infrastructure should be designed to recover correctly after events such as:

* Reboots
* Instance replacements
* Auto Scaling events
* Infrastructure maintenance

---

# 3. Security Group Configuration

## Challenge

As the architecture grew, different services required different network access.

Opening all traffic would have made troubleshooting easier, but it would also have unnecessarily exposed the infrastructure.

## Solution

I configured Security Groups based on the function of each resource.

Examples included:

```text
HTTPS → TCP 443
HTTP  → TCP 80
SSH   → TCP 22
NFS   → TCP 2049
```

Access was restricted based on which resources actually needed to communicate.

For example, EFS NFS access was limited to the web server Security Group rather than being opened publicly.

## Lesson Learned

Security Groups should follow the **principle of least privilege**.

The goal is not simply to make the application work. The goal is to allow the required communication while minimizing unnecessary exposure.

---

# 4. DNS Propagation

## Challenge

During the project, DNS changes did not always appear immediately.

After changing DNS records, the application could still resolve to an older destination while DNS information was propagating.

## Troubleshooting

I checked:

* DNS record values
* Record type
* Domain/subdomain configuration
* TTL
* DNS propagation
* Application endpoint

I also used DNS checking tools to confirm whether the updated records had propagated to different locations.

## Lesson Learned

DNS changes are not always instantaneous.

When troubleshooting DNS, I learned to distinguish between:

* Incorrect DNS configuration
* Cached DNS information
* DNS propagation delay
* Application/infrastructure problems

---

# 5. SSL/TLS Certificate Validation

## Challenge

The AWS Certificate Manager certificate took longer than expected to validate.

This initially made it unclear whether the problem was with the certificate request or the infrastructure.

## Troubleshooting

I reviewed:

* Domain name
* DNS validation records
* Certificate status
* DNS propagation
* Application subdomain

The application domain used for the project is:

```text
app.bfithub.store
```

## Lesson Learned

Certificate validation depends heavily on correct DNS configuration.

HTTPS troubleshooting requires understanding the relationship between:

**Domain → DNS → Certificate → Load Balancer → HTTPS Listener**

---

# 6. Application Load Balancer and HTTPS

## Challenge

I needed to understand the relationship between the SSL/TLS certificate and the Application Load Balancer listener.

Initially, I was unsure whether the load balancer needed an HTTPS listener before the certificate could be used.

## Solution

I learned that certificate validation and load balancer listener configuration are separate processes.

Once the certificate is validated, it can be associated with an:

```text
HTTPS : 443
```

listener on the Application Load Balancer.

## Lesson Learned

HTTPS involves multiple layers.

A certificate alone does not automatically make an application available over HTTPS.

The load balancer must also be configured to accept HTTPS traffic and use the appropriate certificate.

---

# 7. EC2 User Data

## Challenge

Automating EC2 configuration through User Data required careful scripting.

A small problem in the script could result in a new instance launching without being configured correctly.

This becomes particularly important when instances are created automatically through Auto Scaling.

## Troubleshooting

I reviewed:

* Bash syntax
* Package installation
* Directory creation
* EFS mounting
* File permissions
* Network dependencies
* Commands requiring elevated privileges

## Lesson Learned

Automation must be repeatable.

If an Auto Scaling Group launches a replacement server, that server should be able to configure itself with minimal manual intervention.

This reinforced the value of:

* Bash scripting
* Configuration management
* Testing
* Repeatable infrastructure deployment

---

# 8. Shared Website Content

## Challenge

In a load-balanced environment, multiple EC2 instances can serve users.

If every server stores a different copy of the website locally, application content can become inconsistent.

## Solution

Amazon EFS was used as shared storage.

Multiple web servers can access the same website files from the EFS file system.

## Lesson Learned

High availability is not only about having multiple servers.

The application architecture must also consider how those servers access consistent data and application content.

---

# 9. Auto Scaling and Load Balancing

## Challenge

Running multiple EC2 instances does not automatically create a highly available application.

The instances must be integrated correctly with the load balancer and health checks.

## Solution

The Auto Scaling Group was integrated with the Application Load Balancer Target Group.

The load balancer can then direct traffic to healthy application instances.

## Lesson Learned

High availability requires coordination between:

```text
Auto Scaling
     +
Target Groups
     +
Health Checks
     +
Load Balancing
```

These services work together to maintain application availability.

---

# 10. Monitoring with Datadog

## Challenge

Deploying infrastructure successfully does not automatically provide visibility into how that infrastructure is performing.

I needed a way to monitor the environment and identify potential operational problems.

## Solution

I integrated Datadog for infrastructure monitoring.

This provided a foundation for observing infrastructure health and generating alerts when defined conditions were met.

## Lesson Learned

Infrastructure deployment and infrastructure operations are different responsibilities.

A cloud environment should not only be built; it should also be observable.

---

# 11. Slack Alerting

## Challenge

Monitoring information is less useful if an administrator must constantly watch a dashboard.

I wanted important infrastructure alerts to reach a communication platform where they could be noticed quickly.

## Solution

Slack was integrated with the monitoring workflow.

```text
AWS Infrastructure
        ↓
     Datadog
        ↓
      Alert
        ↓
      Slack
```

## Lesson Learned

Monitoring becomes more operationally useful when alerts are delivered to the right people through appropriate communication channels.

This can improve incident awareness and response time.

---

# 12. Troubleshooting Methodology

One of the most important lessons from this project was developing a more structured approach to troubleshooting.

Instead of changing multiple settings at once, I learned to investigate the infrastructure layer by layer.

For networking problems:

```text
VPC
 ↓
Subnet
 ↓
Route Table
 ↓
Gateway
 ↓
Security Group
 ↓
Port
 ↓
Application
```

For HTTPS problems:

```text
Domain
 ↓
DNS
 ↓
Certificate
 ↓
Load Balancer
 ↓
Listener
 ↓
Target Group
 ↓
Web Server
```

For EFS problems:

```text
EFS
 ↓
Mount Target
 ↓
Security Group
 ↓
NFS Port 2049
 ↓
EC2
 ↓
Mount Configuration
```

This approach helped me understand that the visible error is not always where the actual problem originates.

---

# Key Technical Lessons

Through this project, I strengthened my understanding of:

* AWS networking
* VPC architecture
* Public and private subnet design
* Route tables
* Internet and NAT Gateways
* Security Groups
* EC2 administration
* Ubuntu Linux
* Bash scripting
* Amazon EFS
* NFS
* Application Load Balancing
* Auto Scaling
* Target Groups
* Health checks
* DNS
* SSL/TLS certificates
* HTTPS
* Datadog
* Slack alerting
* Git and GitHub
* Technical documentation

---

# Key Professional Lessons

The project also reinforced several broader engineering principles.

### Documentation Matters

Good documentation makes infrastructure easier to understand, troubleshoot, maintain, and reproduce.

### Security Should Be Intentional

Resources should only receive the network access they actually require.

### Automation Reduces Manual Work

Repeatable scripts make server deployment more consistent and scalable.

### Monitoring Is Part of Infrastructure

A successful deployment should include visibility into infrastructure health.

### Troubleshooting Is a Core Cloud Skill

Building the environment was important, but diagnosing why something did not work taught me just as much as the successful deployment.

### Business Value Matters

Cloud infrastructure decisions should connect technical implementation with outcomes such as:

* Availability
* Reliability
* Security
* Scalability
* Operational visibility
* Faster incident response
* Cost awareness

---

# Conclusion

The challenges encountered during the BFitHub project transformed the deployment from a simple technical exercise into a practical cloud engineering learning experience.

Working through EFS connectivity, Security Groups, DNS propagation, certificate validation, HTTPS configuration, server automation, load balancing, Auto Scaling, monitoring, and alerting helped me better understand how individual cloud services depend on one another.

The biggest lesson I took from the project is that **cloud engineering is not simply about creating resources—it is about designing, integrating, securing, monitoring, troubleshooting, and documenting systems that can reliably support an application.**

---

**Project Owner:** Bisola Adebola
**Project:** BFitHub – Highly Available AWS Infrastructure
**Application Domain:** `app.bfithub.store`
