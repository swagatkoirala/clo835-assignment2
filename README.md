# CLO835 Assignment 2 - Part 1: Terraform Setup

This guide outlines the steps to set up and deploy Terraform configurations in an AWS Cloud9 environment for EC2 instance and AWS ECR.

## Step 1: Install Terraform in Cloud9

1. Open the terminal in your Cloud9 environment.
2. Run the following commands to install Terraform:
   ```bash
   sudo yum install -y yum-utils
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   sudo yum -y install terraform
   ```

## Step 2: Initialize and Apply Terraform for network

1. Navigate to the `terraform/network` directory:
   ```bash
   cd /terraform/network
   ```
2. Run the following Terraform commands:
   ```bash
   terraform init
   terraform apply --auto-approve
   ```

## Step 3: Create a Global SSH Key

1. Generate an SSH key to be used for environment in `/terraform` directory:
   ```bash
   ssh-keygen -t rsa -b 2048 -f assignment2
   ```

## Step 4: Initialize and Apply Terraform for webserver

1. Navigate to the `terraform/webserver` directory:
   ```bash
   cd /terraform/webserver
   ```
2. Run the following Terraform commands:
   ```bash
   terraform init
   terraform apply --auto-approve
   ```

# CLO835 Assignment 2 - Part 2: Kubernetes Deployment

This repository contains Kubernetes manifests to deploy the containerized application from Assignment 1 to a local Kubernetes cluster using kind.

## Prerequisites

1. Amazon EC2 instance with sufficient capacity to run kind
2. Docker installed on the EC2 instance
3. AWS CLI configured with valid credentials (to pull images from ECR)
4. Container images for MySQL and the web application already pushed to Amazon ECR

```bash
sudo ssh -i assignmnet2 <public-ip>
```

## Setup

1. Clone this repository to your EC2 instance
2. Install Docker if not already installed then give the required usermod permission

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```
3. Run the setup script to install required tools and create the kind cluster:

```bash
chmod +x deployment.sh
./deployment.sh
```

## Manifests

The following Kubernetes manifests are included:

- `namespace.yaml`: Creates the MySQL and webapp namespaces
- `mysql-pod.yaml`: Deploys the MySQL database as a pod
- `webapp-pod.yaml`: Deploys the web application as a pod
- `mysql-replicaset.yaml`: Creates a ReplicaSet for MySQL
- `webapp-replicaset.yaml`: Creates a ReplicaSet with 3 replicas for the web application
- `mysql-deployment.yaml`: Creates a Deployment for MySQL
- `webapp-deployment.yaml`: Creates a Deployment for the web application (v0.1)
- `webapp-deployment-v2.yaml`: Updated Deployment for the web application (v0.2)
- `mysql-service.yaml`: Exposes MySQL as a ClusterIP service
- `webapp-service.yaml`: Exposes the web application as a NodePort service on port 30000

## Manual Deployment Steps

Generated a deployment script file in the repository but if you prefer to deploy the manifests manually, follow these steps:

1. Create the namespaces:
   ```bash
   kubectl apply -f namespace-manifests.yaml
   ```

2. Deploy the MySQL and web application pods:
   ```bash
   kubectl apply -f mysql-pod.yaml
   kubectl apply -f webapp-pod.yaml
   ```

3. Check pod status:
   ```bash
   kubectl get pods -n mysql
   kubectl get pods -n webapp
   ```

4. Deploy the ReplicaSets:
   ```bash
   kubectl apply -f mysql-replicaset.yaml
   kubectl apply -f webapp-replicaset.yaml
   ```

5. Deploy the Services:
   ```bash
   kubectl apply -f mysql-service.yaml
   kubectl apply -f webapp-service.yaml
   ```

6. Deploy the Deployments:
   ```bash
   kubectl apply -f mysql-deployment.yaml
   kubectl apply -f webapp-deployment.yaml
   ```

7. Update the web application to version 0.2:
   ```bash
   kubectl apply -f webapp-deployment-v2.yaml
   ```

8. Access the web application through NodePort:
   ```bash
   curl http://localhost:30000
   ```