# Gateway API Setup for AWS EKS

This directory contains resources for deploying Kubernetes Gateway API on AWS EKS with the AWS Gateway API Controller (VPC Lattice integration).

## Overview

The Gateway API is the next-generation ingress API for Kubernetes, providing:
- **Role-oriented design**: Separate concerns for infrastructure providers, cluster operators, and application developers
- **Expressive routing**: Advanced traffic management capabilities
- **Portable**: Standard API across different implementations
- **Integration with AWS VPC Lattice**: Service mesh capabilities without sidecar proxies

## Components

1. **Gateway API CRDs**: Core Custom Resource Definitions (GatewayClass, Gateway, HTTPRoute, etc.)
2. **AWS Gateway API Controller**: AWS-specific implementation that integrates with VPC Lattice

## Installation

### Prerequisites

1. **IAM Permissions**: Create IRSA role for the Gateway Controller with VPC Lattice permissions
2. **EKS Cluster**: Running Kubernetes 1.24+
3. **Helm 3.8+**

### Step 1: Install Gateway API CRDs

```bash
# Install the standard Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

Or use the Helm chart for CRDs:

```bash
helm repo add gateway-api https://gateway-api.sigs.k8s.io
helm repo update
helm install gateway-api-crds gateway-api/gateway-api-crds --namespace gateway-system --create-namespace
```

### Step 2: Create IAM Role for Service Account (IRSA)

The AWS Gateway API Controller needs permissions to manage VPC Lattice resources:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "vpc-lattice:*",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

Create the IRSA role:

```bash
eksctl create iamserviceaccount \
  --cluster=<CLUSTER_NAME> \
  --namespace=gateway-system \
  --name=aws-gateway-controller \
  --attach-policy-arn=arn:aws:iam::<ACCOUNT_ID>:policy/GatewayControllerPolicy \
  --approve \
  --override-existing-serviceaccounts
```

### Step 3: Install AWS Gateway API Controller

```bash
# Login to Amazon ECR Public
aws ecr-public get-login-password --region us-east-1 | \
  helm registry login --username AWS --password-stdin public.ecr.aws

# Install the controller
helm install aws-gateway-controller \
  oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart \
  --version v1.0.0 \
  --namespace gateway-system \
  --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-gateway-controller
```

Or add to ArgoCD `applications.yaml`:

```yaml
- namespace: gateway-system
  applications:
    - name: gateway-api-crds
      path: external/gateway-api/gateway-api-crds/1.0.0
      targetRevision: openprime-init-integration
    - name: aws-gateway-controller
      path: external/aws/aws-gateway-controller
      targetRevision: openprime-init-integration
```

## Running in Parallel with Ingress-nginx

To run Gateway API alongside ingress-nginx:

1. **Different Namespaces**: Gateway API in `gateway-system`, ingress-nginx in `ingress-nginx`
2. **Different Service Selectors**: Use labels to route traffic appropriately
3. **Gradual Migration**:
   - Keep existing ingress-nginx for current workloads
   - Deploy new services using Gateway API (HTTPRoute)
   - Gradually migrate existing services
   - Eventually deprecate ingress-nginx

### Example: Parallel Deployment

**Existing Ingress (ingress-nginx):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app
                port:
                  number: 80
```

**New Gateway API (AWS Gateway Controller):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app-route
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "app-new.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: my-app
          port: 80
```

## Benefits of VPC Lattice Integration

- **No sidecar proxies**: Lower resource overhead
- **Cross-cluster communication**: Connect services across multiple EKS clusters
- **Service mesh without complexity**: Traffic management without Istio/Linkerd complexity
- **AWS-native**: Integrated with AWS networking and security

## Next Steps

1. Install Gateway API CRDs
2. Deploy AWS Gateway API Controller
3. Create GatewayClass and Gateway resources
4. Migrate selected workloads to HTTPRoute
5. Monitor and validate traffic routing
6. Plan full migration strategy

## Resources

- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [AWS Gateway API Controller GitHub](https://github.com/aws/aws-application-networking-k8s)
- [VPC Lattice Documentation](https://docs.aws.amazon.com/vpc-lattice/)
