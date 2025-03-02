#!/bin/bash

# Install kind
if ! command -v kind &> /dev/null; then
  echo "Installing kind..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/
  echo "kind installed successfully"
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv ./kubectl /usr/local/bin/
  echo "kubectl installed successfully"
fi

# Create a kind config file
cat > kind-config.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
EOF

# Create a kind cluster
echo "Creating kind cluster..."
kind create cluster --config=kind-config.yaml --name clo835-assignment2

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Set up ECR credentials to pull images
echo "Setting up ECR credentials..."
ECR_REGISTRY=$(aws ecr get-authorization-token --region us-east-1 --output text --query 'authorizationData[].proxyEndpoint' | sed 's|https://||')
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

# Pull images from ECR and load them into kind
echo "Pulling images from ECR and loading into kind..."
docker pull $ECR_REGISTRY/clo835-assignment2-sql-image:v0.1
docker pull $ECR_REGISTRY/clo835-assignment2-webapp-image:v0.1
docker pull $ECR_REGISTRY/clo835-assignment2-webapp-image:v0.2

# Tag images for kind
docker tag $ECR_REGISTRY/clo835-assignment2-sql-image:v0.1 clo835-assignment2-sql-image:v0.1
docker tag $ECR_REGISTRY/clo835-assignment2-webapp-image:v0.1 clo835-assignment2-webapp-image:v0.1
docker tag $ECR_REGISTRY/clo835-assignment2-webapp-image:v0.2 clo835-assignment2-webapp-image:v0.2

# Load images into kind
kind load docker-image clo835-assignment2-sql-image:v0.1 --name clo835-assignment2
kind load docker-image clo835-assignment2-webapp-image:v0.1 --name clo835-assignment2
kind load docker-image clo835-assignment2-webapp-image:v0.2 --name clo835-assignment2

# Update manifest files with correct registry information
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-sql-image|g" mysql-pod.yaml
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-webapp-image|g" webapp-pod.yaml
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-sql-image|g" mysql-replicaset.yaml
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-webapp-image|g" webapp-replicaset.yaml
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-sql-image|g" mysql-deployment.yaml
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-webapp-image|g" webapp-deployment.yaml
sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-webapp-image|g" webapp-deployment-v2.yaml

# Create namespaces
echo "Creating namespaces..."
kubectl apply -f namespace.yaml

# Deploy MySQL and webapp pods
echo "Deploying MySQL and webapp pods..."
kubectl apply -f mysql-pod.yaml
kubectl apply -f webapp-pod.yaml

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod/mysql-pod -n mysql --timeout=120s
kubectl wait --for=condition=Ready pod/webapp-pod -n webapp --timeout=120s

# Check pod status
kubectl get pods -n mysql
kubectl get pods -n webapp

# Test webapp connection
echo "Testing webapp connection..."
kubectl port-forward -n webapp pod/webapp-pod 8080:8080 --address 0.0.0.0 &
PF_PID=$!
sleep 5
curl http://localhost:8080

# Check webapp logs
kubectl logs -n webapp pod/webapp-pod

# Kill the port-forward process
kill $PF_PID

# Deploy ReplicaSets
echo "Deploying ReplicaSets..."
kubectl apply -f mysql-replicaset.yaml
kubectl apply -f webapp-replicaset.yaml

# Check replicasets status
kubectl get rs -n mysql
kubectl get rs -n webapp
kubectl get pods -n webapp -l app=employees

# Deploy Services
echo "Deploying Services..."
kubectl apply -f mysql-service.yaml
kubectl apply -f webapp-service.yaml

# Check services status
kubectl get svc -n mysql
kubectl get svc -n webapp

# Test NodePort service
echo "Testing NodePort service..."
curl http://localhost:30000

# Deploy Deployments
echo "Deploying Deployments..."
kubectl apply -f mysql-deployment.yaml
kubectl apply -f webapp-deployment.yaml

# Check deployments status
kubectl get deploy -n mysql
kubectl get deploy -n webapp
kubectl get pods -n webapp -l app=employees

# Update webapp to version 0.2
echo "Updating webapp to version 0.2..."
kubectl apply -f webapp-deployment-v2.yaml

# Check updated deployment
kubectl rollout status deployment/webapp-deployment -n webapp
kubectl get pods -n webapp -l app=employees
kubectl describe deployment webapp-deployment -n webapp

# Test the updated application
curl http://localhost:30000

echo "Deployment complete!"