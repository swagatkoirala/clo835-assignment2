#!/bin/bash

# Set your ECR registry URL here
ECR_REGISTRY="your-aws-account-id.dkr.ecr.us-east-1.amazonaws.com"

# Alternatively, you can detect it automatically if you have AWS CLI configured
# ECR_REGISTRY=$(aws ecr get-authorization-token --region us-east-1 --output text --query 'authorizationData[].proxyEndpoint' | sed 's|https://||')

# List of manifest files to update
MANIFEST_FILES=(
  "mysql-pod.yaml"
  "webapp-pod.yaml"
  "mysql-replicaset.yaml"
  "webapp-replicaset.yaml"
  "mysql-deployment.yaml"
  "webapp-deployment.yaml"
  "webapp-deployment-v2.yaml"
)

# Update each file
for file in "${MANIFEST_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Updating $file with ECR registry: $ECR_REGISTRY"
    # Create a temporary file
    tmp_file=$(mktemp)
    # Replace the placeholder with the actual ECR registry
    sed "s|\${ECR_REGISTRY}|$ECR_REGISTRY|g" "$file" > "$tmp_file"
    # Move the temp file to the original
    mv "$tmp_file" "$file"
  else
    echo "Warning: File $file not found"
  fi
done

echo "All manifest files have been updated with the ECR registry: $ECR_REGISTRY"