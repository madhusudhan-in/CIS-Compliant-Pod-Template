# CIS Compliant Pod Template - Enterprise Production Grade

A comprehensive, enterprise-grade Kubernetes Pod template that implements CIS (Center for Internet Security) compliance standards and best practices for production environments.

## 🚀 Features

### Security & Compliance
- **CIS Level 2 Compliance**: Implements comprehensive security controls
- **Pod Security Standards**: Enforces restricted security policies
- **Runtime Security**: Seccomp profiles, capabilities management, and SELinux options
- **Network Security**: Host network isolation and secure port configurations
- **File System Security**: Read-only root filesystem and secure volume mounts

### Enterprise Features
- **Resource Management**: QoS-aware resource limits and requests
- **High Availability**: Anti-affinity rules and node affinity for security
- **Monitoring & Observability**: Prometheus metrics, health checks, and logging
- **Lifecycle Management**: Graceful shutdown and startup procedures
- **Configuration Management**: ConfigMaps and Secrets integration

### CI/CD Pipeline Integration
- **Helm Chart Compatible**: Template variables for dynamic configuration
- **Multi-Environment Support**: Production, staging, and development configurations
- **Security Scanning**: Integration with container security tools
- **Compliance Validation**: Automated security policy checks

## 📋 Prerequisites

- Kubernetes cluster 1.21+
- Pod Security Standards enabled
- Helm 3.0+ (for template rendering)
- Container runtime with seccomp support
- SELinux enabled (if using SELinux policies)

## 🛠️ Installation & Usage

### 1. Basic Usage

```bash
# Apply the template directly
kubectl apply -f CIS-Compliant-Pod-Template.yaml

# Or use with Helm
helm template my-app . -f values.yaml | kubectl apply -f -
```

### 2. Helm Chart Integration

Create a `values.yaml` file:

```yaml
# Image configuration
image:
  repository: your-registry/your-app
  tag: "1.0.0"
  digest: "sha256:abc123..."

# Resource configuration
resources:
  limits:
    memory: "512Mi"
    cpu: "1000m"
  requests:
    memory: "256Mi"
    cpu: "500m"

# Configuration
config:
  name: "app-config"
  key: "config.yaml"
  path: "config.yaml"
  subPath: ""

# Service account
serviceAccount:
  name: "app-service-account"

# Image pull secrets
imagePullSecrets:
  name: "registry-secret"
```

### 3. CI/CD Pipeline Integration

#### GitHub Actions Example

```yaml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'latest'
    
    - name: Deploy to cluster
      run: |
        # Generate config checksum for rolling updates
        CONFIG_CHECKSUM=$(sha256sum values.yaml | cut -d' ' -f1)
        sed -i "s/{{ .Values.configChecksum }}/$CONFIG_CHECKSUM/g" CIS-Compliant-Pod-Template.yaml
        
        kubectl apply -f CIS-Compliant-Pod-Template.yaml
```

#### GitLab CI Example

```yaml
deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config set-cluster k8s --server="$KUBE_URL"
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
    
    # Deploy with config validation
    - kubectl apply -f CIS-Compliant-Pod-Template.yaml
    - kubectl rollout status deployment/secure-app
```

## 🔒 Security Features

### Pod Security Context
- **Non-root execution**: Runs as unprivileged user (UID 1000)
- **Capability restrictions**: Drops all Linux capabilities except NET_BIND_SERVICE
- **Read-only filesystem**: Prevents runtime modifications
- **Seccomp profiles**: Runtime security policies

### Network Security
- **Host isolation**: No host network, PID, or IPC sharing
- **Port restrictions**: Only necessary ports exposed
- **Service mesh compatibility**: Istio integration support

### Volume Security
- **ConfigMap integration**: Secure configuration management
- **Secret mounting**: Certificate and key management
- **Temporary storage**: Memory-backed ephemeral storage
- **Access controls**: Proper file permissions and ownership

## 📊 Monitoring & Observability

### Health Checks
- **Liveness probe**: Application health monitoring
- **Readiness probe**: Service readiness verification
- **Startup probe**: Initialization monitoring

### Metrics & Logging
- **Prometheus metrics**: `/metrics` endpoint for monitoring
- **Structured logging**: JSON-formatted log output
- **Log aggregation**: Centralized logging support

### Resource Monitoring
- **Resource limits**: Memory and CPU constraints
- **Storage quotas**: Ephemeral storage management
- **QoS classification**: Guaranteed resource allocation

## 🏗️ Architecture

### Node Affinity
- **Security nodes**: Deploy to dedicated security nodes
- **OS requirements**: Linux-only deployment
- **Resource isolation**: Anti-affinity for high availability

### Resource Management
- **Priority classes**: High-priority scheduling
- **Tolerations**: Dedicated node deployment
- **Resource quotas**: Enforced limits and requests

## 🔧 Customization

### Environment-Specific Configurations

#### Development
```yaml
environment: development
resources:
  limits:
    memory: "128Mi"
    cpu: "250m"
  requests:
    memory: "64Mi"
    cpu: "100m"
```

#### Staging
```yaml
environment: staging
resources:
  limits:
    memory: "256Mi"
    cpu: "500m"
  requests:
    memory: "128Mi"
    cpu: "250m"
```

#### Production
```yaml
environment: production
resources:
  limits:
    memory: "1Gi"
    cpu: "2000m"
  requests:
    memory: "512Mi"
    cpu: "1000m"
```

### Security Policy Customization

```yaml
# Custom security policies
securityContext:
  seLinuxOptions:
    level: "s0:c123,c456"
  sysctls:
    - name: net.ipv4.tcp_max_syn_backlog
      value: "8192"
```

## 🧪 Testing & Validation

### Security Scanning
```bash
# Run security scans
trivy config .
kubesec scan CIS-Compliant-Pod-Template.yaml
```

### Compliance Validation
```bash
# Validate against policies
kubectl apply -f - <<EOF
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-security-labels
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
  parameters:
    labels: ["compliance", "security"]
EOF
```

### Load Testing
```bash
# Test resource limits
kubectl exec -it secure-pod -- stress-ng --cpu 4 --timeout 60s
```

## 📚 Best Practices

### 1. Regular Updates
- Update base images monthly
- Rotate secrets and certificates
- Review security policies quarterly

### 2. Monitoring
- Set up alerts for resource usage
- Monitor security events
- Track compliance status

### 3. Backup & Recovery
- Backup configurations and secrets
- Document recovery procedures
- Test disaster recovery plans

## 🚨 Troubleshooting

### Common Issues

#### Pod Won't Start
```bash
# Check events
kubectl describe pod secure-pod-template

# Check logs
kubectl logs secure-pod-template

# Verify security policies
kubectl get psp
```

#### Resource Issues
```bash
# Check resource usage
kubectl top pod secure-pod-template

# Verify limits
kubectl describe pod secure-pod-template | grep -A 10 "Limits:"
```

#### Security Violations
```bash
# Check security context
kubectl get pod secure-pod-template -o yaml | grep -A 20 securityContext

# Verify policies
kubectl get psp restricted -o yaml
```

## 📖 References

- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Helm Documentation](https://helm.sh/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the security team
- Review the troubleshooting guide

---

**Note**: This template is designed for production use but should be reviewed and customized according to your specific security requirements and compliance standards.