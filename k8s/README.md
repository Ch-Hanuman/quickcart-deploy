# QuickCart Kubernetes manifests

Each Kubernetes resource has its own YAML file, grouped by resource type.

## Layout

```text
k8s/
├── namespace/
│   └── namespace.yaml
├── configmaps/
│   ├── api-gateway-configmap.yaml
│   ├── inventory-service-configmap.yaml
│   └── order-service-configmap.yaml
├── databases/
│   ├── inventory-db-pvc.yaml
│   ├── inventory-db-deployment.yaml
│   ├── inventory-db-service.yaml
│   ├── order-db-pvc.yaml
│   ├── order-db-deployment.yaml
│   └── order-db-service.yaml
├── deployments/
│   ├── api-gateway-deployment.yaml
│   ├── inventory-service-deployment.yaml
│   └── order-service-deployment.yaml
├── services/
│   ├── api-gateway-service.yaml
│   ├── inventory-service-service.yaml
│   └── order-service-service.yaml
├── hpa/
│   ├── api-gateway-hpa.yaml
│   ├── inventory-service-hpa.yaml
│   └── order-service-hpa.yaml
├── kustomization.yaml
├── build-images.sh
├── deploy.sh
└── delete.sh
```

## Deploy to Minikube

From this `k8s` directory:

```bash
chmod +x *.sh
./deploy.sh
```

Optional database passwords:

```bash
INVENTORY_DB_PASSWORD='change-me' ORDER_DB_PASSWORD='change-me-too' ./deploy.sh
```

The defaults are for local development only.

## Deploy to an existing cluster

Build and push the images to a registry accessible by the cluster, then set the image names/tags in the Deployment YAMLs and `kustomization.yaml`.

```bash
K8S_TARGET=current INVENTORY_DB_PASSWORD='...' ORDER_DB_PASSWORD='...' ./deploy.sh
```

## Validate and apply manually

```bash
kubectl apply -f namespace/namespace.yaml
kubectl apply -k .
kubectl get pods,services,hpa -n quickcart
```

The `deploy.sh` script creates `quickcart-db-secret` before applying the remaining manifests. If applying manually, create that Secret first:

```bash
kubectl create secret generic quickcart-db-secret -n quickcart \
  --from-literal=inventory-db-password='...' \
  --from-literal=order-db-password='...'
```

## Access

The API Gateway Service is a NodePort on `30080`. Application containers all listen on port `8080`; PostgreSQL listens on `5432`.

```bash
minikube service api-gateway -n quickcart --url
```

## Useful commands

```bash
kubectl get pods,svc,hpa -n quickcart
kubectl get endpointslice -n quickcart
kubectl logs -f deployment/api-gateway -n quickcart
kubectl logs -f deployment/order-service -n quickcart
kubectl logs -f deployment/inventory-service -n quickcart
```

## Notes

- ConfigMaps contain non-sensitive configuration. Database passwords are created as a Kubernetes Secret by `deploy.sh`, not committed in YAML.
- Kubernetes Secrets are not encrypted merely because they are Secret objects. Configure encryption at rest and RBAC in shared/production clusters.
- PostgreSQL Deployments are single-replica examples with PVCs. For production, use managed databases or a properly operated database cluster, backups, monitoring and tested recovery.
- HPA requires Metrics Server and CPU requests. The Minikube script enables Metrics Server.
- `kubectl delete -k .` removes PVC objects as well; take care with persistent data.
