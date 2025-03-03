#!/bin/bash
# Exit on any error
set -e

# Install kind if not already installed
if ! command -v kind &> /dev/null; then
  echo "Installing kind..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/
  echo "kind installed successfully"
fi

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv ./kubectl /usr/local/bin/
  echo "kubectl installed successfully"
fi

# Check if the kind cluster already exists
if ! kind get clusters | grep -q "clo835-assignment2"; then
  echo "Creating kind cluster..."
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
  kind create cluster --config=kind-config.yaml --name clo835-assignment2
else
  echo "Kind cluster already exists. Skipping creation."
fi

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Set up ECR credentials to pull images
ECR_REGISTRY=$(aws ecr get-authorization-token --region us-east-1 --output text --query 'authorizationData[].proxyEndpoint' | sed 's|https://||')
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

# List of required images
IMAGES=(
  "clo835-assignment2-sql-image:v0.1"
  "clo835-assignment2-webapp-image:v0.1"
  "clo835-assignment2-webapp-image:v0.2"
)

# Pull and load images into kind if not already present
for IMAGE in "${IMAGES[@]}"; do
  if ! docker images | grep -q "$IMAGE"; then
    echo "Pulling image $IMAGE from ECR..."
    docker pull "$ECR_REGISTRY/$IMAGE"
    docker tag "$ECR_REGISTRY/$IMAGE" "$IMAGE"
  fi
  kind load docker-image "$IMAGE" --name clo835-assignment2
done

# Update manifest files with correct image names
for FILE in mysql-pod.yaml webapp-pod.yaml mysql-replicaset.yaml webapp-replicaset.yaml mysql-deployment.yaml webapp-deployment.yaml webapp-deployment-v2.yaml; do
  if [[ "$FILE" == *"mysql"* ]]; then
    sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-sql-image|g" "$FILE"
  elif [[ "$FILE" == *"webapp"* ]]; then
    sed -i "s|\${ECR_REGISTRY}|clo835-assignment2-webapp-image|g" "$FILE"
  fi
  echo "Updated $FILE with correct image names"
done

# Create namespaces if they don't exist
if ! kubectl get ns | grep -q "mysql"; then
  kubectl apply -f namespace.yaml
fi

# Deploy MySQL and webapp pods if they are not running
if ! kubectl get pods -n mysql | grep -q "mysql-pod"; then
  kubectl apply -f mysql-pod.yaml
fi
if ! kubectl get pods -n webapp | grep -q "webapp-pod"; then
  kubectl apply -f webapp-pod.yaml
fi

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod/mysql-pod -n mysql --timeout=120s
kubectl wait --for=condition=Ready pod/webapp-pod -n webapp --timeout=120s

# Check pod status
kubectl get pods -n mysql
kubectl get pods -n webapp

echo "Deployment complete untill the pods are created!"