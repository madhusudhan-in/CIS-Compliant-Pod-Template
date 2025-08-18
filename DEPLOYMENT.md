# Deployment Guide - CIS Compliant Pod Template

This guide provides comprehensive instructions for deploying the enterprise-grade CIS compliant pod template across different environments and CI/CD pipelines.

## Quick Start

### 1. Prerequisites

- Kubernetes cluster 1.21+
- kubectl configured and authenticated
- Helm 3.0+ (optional, for advanced usage)
- Access to container registry

### 2. Basic Deployment

```bash
# Clone the repository
git clone <your-repo-url>
cd CIS-Compliant-Pod-Template

# Apply the template directly
kubectl apply -f CIS-Compliant-Pod-Template.yaml

# Verify deployment
kubectl get pods -l app=secure-app
kubectl describe pod secure-pod-template
```

## 🔧 Environment-Specific Deployments

### Development Environment

```bash
# Create development namespace
kubectl create namespace development

# Apply with development-specific values
kubectl apply -f CIS-Compliant-Pod-Template.yaml -n development

# Or use Helm with development values
helm template my-app . -f values-dev.yaml | kubectl apply -f -
```

**Development values.yaml:**
```yaml
metadata:
  namespace: development
  labels:
    environment: development
resources:
  limits:
    memory: "128Mi"
    cpu: "250m"
  requests:
    memory: "64Mi"
    cpu: "100m"
```

### Staging Environment

```bash
# Create staging namespace
kubectl create namespace staging

# Apply with staging-specific values
kubectl apply -f CIS-Compliant-Pod-Template.yaml -n staging

# Or use Helm with staging values
helm template my-app . -f values-staging.yaml | kubectl apply -f -
```

**Staging values.yaml:**
```yaml
metadata:
  namespace: staging
  labels:
    environment: staging
resources:
  limits:
    memory: "256Mi"
    cpu: "500m"
  requests:
    memory: "128Mi"
    cpu: "250m"
```

### Production Environment

```bash
# Create production namespace
kubectl create namespace production

# Apply with production-specific values
kubectl apply -f CIS-Compliant-Pod-Template.yaml -n production

# Or use Helm with production values
helm template my-app . -f values-prod.yaml | kubectl apply -f -
```

**Production values.yaml:**
```yaml
metadata:
  namespace: production
  labels:
    environment: production
resources:
  limits:
    memory: "1Gi"
    cpu: "2000m"
  requests:
    memory: "512Mi"
    cpu: "1000m"
```

## Security Configuration

### 1. Service Account Setup

```bash
# Create service account
kubectl create serviceaccount app-service-account -n <namespace>

# Create role and role binding
kubectl create role app-role --verb=get,list,watch --resource=pods,services -n <namespace>
kubectl create rolebinding app-role-binding --role=app-role --serviceaccount=<namespace>:app-service-account -n <namespace>
```

### 2. Secrets Management

```bash
# Create TLS certificate secret
kubectl create secret tls app-certs \
  --cert=path/to/cert.pem \
  --key=path/to/key.pem \
  -n <namespace>

# Create registry secret
kubectl create secret docker-registry registry-secret \
  --docker-server=<registry-url> \
  --docker-username=<username> \
  --docker-password=<password> \
  -n <namespace>
```

### 3. ConfigMap Creation

```bash
# Create configuration ConfigMap
kubectl create configmap app-config \
  --from-file=config.yaml=path/to/config.yaml \
  -n <namespace>
```

## CI/CD Pipeline Integration

### GitHub Actions

The repository includes a comprehensive GitHub Actions workflow that:

1. **Security Scanning**: Runs Trivy, Kubesec, and OPA policy validation
2. **Image Building**: Builds and pushes container images with security scanning
3. **Multi-Environment Deployment**: Deploys to development, staging, and production
4. **Compliance Validation**: Ensures CIS compliance standards are met

#### Setup Steps:

1. **Configure Secrets**:
   ```bash
   # Add these secrets to your GitHub repository
   DEV_KUBE_CONFIG=<base64-encoded-kubeconfig>
   STAGING_KUBE_CONFIG=<base64-encoded-kubeconfig>
   PROD_KUBE_CONFIG=<base64-encoded-kubeconfig>
   ```

2. **Enable Environments**:
   - Go to Settings > Environments
   - Create `development`, `staging`, and `production` environments
   - Configure protection rules and required reviewers

3. **Trigger Deployment**:
   ```bash
   # Automatic deployment on push
   git push origin main      # Deploys to staging
   git push origin develop   # Deploys to development
   
   # Manual deployment
   # Go to Actions > Deploy CIS Compliant Pod > Run workflow
   ```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - security
  - build
  - deploy

security-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy config .
    - trivy fs --security-checks vuln,config,secret .

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl apply -f CIS-Compliant-Pod-Template.yaml
  environment:
    name: production
    url: https://your-app.com
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Security Scan') {
            steps {
                sh 'trivy config .'
                sh 'kubesec scan CIS-Compliant-Pod-Template.yaml'
            }
        }
        
        stage('Build') {
            steps {
                sh 'docker build -t app:latest .'
                sh 'docker push app:latest'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f CIS-Compliant-Pod-Template.yaml'
                sh 'kubectl rollout status deployment/secure-app'
            }
        }
    }
}
```

## 🔍 Monitoring and Observability

### 1. Prometheus Metrics

The pod template includes Prometheus annotations for automatic metric collection:

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

### 2. Health Check Endpoints

Ensure your application implements these endpoints:

- `/health` - Liveness probe
- `/ready` - Readiness probe  
- `/startup` - Startup probe
- `/metrics` - Prometheus metrics

### 3. Logging Configuration

```yaml
# Configure logging
env:
  - name: LOG_LEVEL
    value: "info"
  - name: LOG_FORMAT
    value: "json"
```

## 🛡️ Security Validation

### 1. Policy Enforcement with OPA/Gatekeeper

```bash
# Install Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# Apply security policies
kubectl apply -f policies/security-policy.rego
```

### 2. Pod Security Standards

```bash
# Verify Pod Security Standards
kubectl get psp
kubectl describe psp restricted

# Check if pods comply
kubectl get pods -o yaml | grep -A 20 securityContext
```

### 3. Security Scanning

```bash
# Run Trivy scan
trivy config .

# Run Kubesec scan
kubesec scan CIS-Compliant-Pod-Template.yaml

# Run OPA validation
opa eval --data policies/security-policy.rego --input CIS-Compliant-Pod-Template.yaml "data.kubernetes.admission.deny"
```

## 🔧 Customization

### 1. Resource Requirements

Adjust resource limits based on your application needs:

```yaml
resources:
  limits:
    memory: "2Gi"    # Adjust based on app requirements
    cpu: "2000m"     # Adjust based on app requirements
  requests:
    memory: "1Gi"    # Adjust based on app requirements
    cpu: "1000m"     # Adjust based on app requirements
```

### 2. Security Context

Customize security settings for your use case:

```yaml
securityContext:
  runAsUser: 1000        # Custom user ID
  runAsGroup: 3000       # Custom group ID
  fsGroup: 2000          # Custom filesystem group
  seLinuxOptions:
    level: "s0:c123,c456" # Custom SELinux level
```

### 3. Volume Mounts

Add additional volumes as needed:

```yaml
volumes:
  - name: additional-volume
    persistentVolumeClaim:
      claimName: app-data-pvc
  - name: shared-volume
    emptyDir:
      medium: Memory
      sizeLimit: "500Mi"
```

## Troubleshooting

### Common Issues

#### 1. Pod Won't Start

```bash
# Check events
kubectl describe pod secure-pod-template

# Check logs
kubectl logs secure-pod-template

# Verify security policies
kubectl get psp
```

#### 2. Security Context Violations

```bash
# Check security context
kubectl get pod secure-pod-template -o yaml | grep -A 20 securityContext

# Verify policies
kubectl get psp restricted -o yaml
```

#### 3. Resource Issues

```bash
# Check resource usage
kubectl top pod secure-pod-template

# Verify limits
kubectl describe pod secure-pod-template | grep -A 10 "Limits:"
```

#### 4. Network Issues

```bash
# Check network policies
kubectl get networkpolicies

# Test connectivity
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -f http://secure-pod-template:8080/health
```

### Debug Commands

```bash
# Get detailed pod information
kubectl get pod secure-pod-template -o yaml

# Check events across namespace
kubectl get events --sort-by='.lastTimestamp'

# Verify ConfigMaps and Secrets
kubectl get configmaps,secrets

# Check service account
kubectl get serviceaccount app-service-account -o yaml
```

## 📊 Performance Optimization

### 1. Resource Optimization

```yaml
# Optimize resource allocation
resources:
  limits:
    memory: "1Gi"     # Set realistic limits
    cpu: "1000m"      # Set realistic limits
  requests:
    memory: "512Mi"   # Set realistic requests
    cpu: "500m"       # Set realistic requests
```

### 2. Probe Optimization

```yaml
# Optimize probe settings
livenessProbe:
  initialDelaySeconds: 30    # Adjust based on startup time
  periodSeconds: 10          # Adjust based on app behavior
  timeoutSeconds: 5          # Adjust based on response time
  failureThreshold: 3        # Adjust based on tolerance

readinessProbe:
  initialDelaySeconds: 5     # Adjust based on startup time
  periodSeconds: 5           # Adjust based on app behavior
  timeoutSeconds: 3          # Adjust based on response time
  failureThreshold: 3        # Adjust based on tolerance
```

### 3. Volume Optimization

```yaml
# Optimize volume usage
volumes:
  - name: tmp-volume
    emptyDir:
      medium: Memory         # Use memory for temporary files
      sizeLimit: "100Mi"    # Set appropriate size limit
```

## Rolling Updates

### 1. Update Strategy

```bash
# Perform rolling update
kubectl set image deployment/secure-app secure-container=new-image:tag

# Monitor rollout
kubectl rollout status deployment/secure-app

# Rollback if needed
kubectl rollout undo deployment/secure-app
```

### 2. Blue-Green Deployment

```bash
# Create new deployment
kubectl apply -f CIS-Compliant-Pod-Template-v2.yaml

# Switch traffic
kubectl patch service secure-app-service -p '{"spec":{"selector":{"version":"v2"}}}'

# Remove old deployment
kubectl delete deployment secure-app-v1
```

## Best Practices

### 1. Security

- Always use non-root containers
- Implement least privilege principle
- Regular security scanning and updates
- Monitor security events and violations

### 2. Resource Management

- Set realistic resource limits and requests
- Monitor resource usage and adjust as needed
- Implement horizontal pod autoscaling
- Use resource quotas and limits

### 3. Monitoring

- Implement comprehensive health checks
- Set up alerting for critical metrics
- Monitor security compliance
- Track performance metrics

### 4. Documentation

- Document all customizations
- Maintain deployment runbooks
- Update security policies regularly
- Document troubleshooting procedures

## Support

For additional support:

1. **Check the troubleshooting section** above
2. **Review the README.md** for comprehensive documentation
3. **Create an issue** in the repository

---

**Note**: This deployment guide should be customized based on your specific infrastructure, security requirements, and compliance standards. 
