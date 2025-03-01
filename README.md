# CLO835 Assignment 2 - Kubernetes Deployment

This repository contains Kubernetes manifests to deploy the containerized application from Assignment 1 to a local Kubernetes cluster using kind.

## Prerequisites

1. Amazon EC2 instance with sufficient capacity to run kind
2. Docker installed on the EC2 instance
3. AWS CLI configured with valid credentials (to pull images from ECR)
4. Container images for MySQL and the web application already pushed to Amazon ECR

## Setup

1. Clone this repository to your EC2 instance
2. Ensure all manifest files have the correct ECR registry information (replace `${ECR_REGISTRY}` with your ECR repository URI)
3. Run the setup script to install required tools and create the kind cluster:

```bash
chmod +x k8s-setup-script.sh
./k8s-setup-script.sh
```

## Manifests

The following Kubernetes manifests are included:

- `namespace-manifests.yaml`: Creates the MySQL and webapp namespaces
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

If you prefer to deploy the manifests manually, follow these steps:

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

## Assignment Report Information

### Key Concepts Addressed

1. **Kubernetes API Server IP**: 
   - In a kind cluster, the API server runs inside the control plane node container. You can get the IP by running:
   ```bash
   kubectl cluster-info
   ```

2. **Applications Listening on Same Port**:
   - Yes, both applications can listen on the same port inside their containers. This is because each pod has its own network namespace, so there's no port conflict between different pods.

3. **ReplicaSet and Pod Relationship**:
   - The pods created separately in step 2 are not governed by the ReplicaSets created in step 3 unless they have the same labels that match the ReplicaSet's selector.

4. **Deployment and ReplicaSet Relationship**:
   - The ReplicaSets created in step 3 are not part of the Deployments created in step 4. Deployments create their own ReplicaSets with different names.

5. **Different Service Types**:
   - We use NodePort for the web application to make it accessible from outside the cluster.
   - We use ClusterIP for MySQL because the database should only be accessible from within the cluster for security reasons.