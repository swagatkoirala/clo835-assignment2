#!/bin/bash

echo "This script will guide you through the steps to demonstrate your K8s deployment for the assignment recording."
echo "Make sure you have the necessary commands ready in another window."
echo "Press Enter to proceed through each step."

read -p "1. Show that your local K8s cluster is running on your Amazon EC2 instance: 
- Run: kubectl cluster-info
- Run: kubectl get nodes
- Run: kubectl get pods -A
Press Enter when ready..."

read -p "2. Deploy MySQL and web applications as pods in their respective namespaces:
- Run: kubectl apply -f namespace-manifests.yaml
- Run: kubectl apply -f mysql-pod.yaml
- Run: kubectl apply -f webapp-pod.yaml
- Run: kubectl get pods -n mysql
- Run: kubectl get pods -n webapp
Press Enter when ready..."

read -p "3. Connect to the server running in the application pod and get a valid response:
- Run: kubectl port-forward -n webapp pod/webapp-pod 8080:8080 --address 0.0.0.0 &
- Run: curl http://localhost:8080
Press Enter when ready..."

read -p "4. Examine the logs of the invoked application:
- Run: kubectl logs -n webapp pod/webapp-pod
Press Enter when ready..."

read -p "5. Deploy ReplicaSets with 3 replicas:
- Run: kubectl apply -f mysql-replicaset.yaml
- Run: kubectl apply -f webapp-replicaset.yaml
- Run: kubectl get rs -n mysql
- Run: kubectl get rs -n webapp
- Run: kubectl get pods -n webapp -l app=employees
Press Enter when ready..."

read -p "6. Create deployments using deployment manifests:
- Run: kubectl apply -f mysql-deployment.yaml
- Run: kubectl apply -f webapp-deployment.yaml
- Run: kubectl get deploy -n mysql
- Run: kubectl get deploy -n webapp
- Run: kubectl get pods -n webapp -l app=employees
Press Enter when ready..."

read -p "7. Expose web application on NodePort 30000:
- Run: kubectl apply -f mysql-service.yaml
- Run: kubectl apply -f webapp-service.yaml
- Run: kubectl get svc -n mysql
- Run: kubectl get svc -n webapp
- Run: curl http://localhost:30000
Press Enter when ready..."

read -p "8. Update the image version and deploy a new version:
- Run: kubectl apply -f webapp-deployment-v2.yaml
- Run: kubectl rollout status deployment/webapp-deployment -n webapp
- Run: kubectl get pods -n webapp -l app=employees
- Run: kubectl describe deployment webapp-deployment -n webapp
- Run: curl http://localhost:30000
Press Enter when ready..."

echo "Demo completed! Make sure you have recorded all the necessary steps."