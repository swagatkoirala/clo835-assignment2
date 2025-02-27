# Kubernetes Deployment for CLO835 Assignment 2

This repository contains Kubernetes manifests for deploying a MySQL database and web application to a kind cluster.

## Prerequisites

- AWS account with ECR repositories set up
- EC2 instance with sufficient capacity to run kind cluster
- GitHub repository with GitHub Actions configured

## Deployment Steps

1. **Push Docker images to ECR**
   - Images are automatically built and pushed to ECR via GitHub Actions workflow
   
2. **Deploy Kubernetes Cluster**
   - GitHub Actions workflow sets up a kind cluster on the EC2 instance
   - Kubernetes manifests are applied in the following order:
     - Namespaces
     - MySQL pod and service
     - Web application pod, ReplicaSet, Deployment, and Service

3. **Update Application**
   - To update the web application to a new version:
     ```bash
     kubectl apply -f k8s/webapp-deployment-v2.yaml
     ```

## Accessing the Application

- The web application is exposed on NodePort 30000
- Access it using: `http://<EC2-PUBLIC-IP>:30000`

## Important Notes for Assignment

1. **API Server IP**: Get the K8s API server IP with `kubectl cluster-info`
2. **Port Usage**: Both applications can listen on the same port inside their containers because they're in separate network namespaces
3. **ReplicaSets and Pods**: Manually created pods aren't governed by ReplicaSets unless they match the selector labels
4. **Deployments and ReplicaSets**: ReplicaSets created manually aren't part of deployments unless they match the deployment's selector
5. **Service Types**: We use different service types because:
   - MySQL (ClusterIP): Internal access only within the cluster
   - Web App (NodePort): External access required for users