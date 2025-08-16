
```markdown
# 🔐 CIS-Compliant Kubernetes Pod Template

This repository provides a secure and CIS Kubernetes Benchmark–compliant Pod manifest that can be used as a baseline for deploying workloads in a hardened Kubernetes environment.

## 📄 Overview

The template is designed to enforce security best practices recommended by the [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes), including:

- Running containers as non-root
- Dropping all Linux capabilities
- Enforcing read-only root filesystems
- Preventing privilege escalation
- Disabling host-level access (PID, IPC, networking)
- Avoiding unnecessary service account token mounting
- Applying a default seccomp profile

## ✅ Key Features

| Feature | Description |
|--------|-------------|
| **Non-root execution** | Containers run as user `1000` and group `3000` |
| **Seccomp profile** | Uses `RuntimeDefault` to restrict syscalls |
| **No privilege escalation** | `allowPrivilegeEscalation: false` |
| **Dropped capabilities** | All Linux capabilities are removed |
| **Read-only filesystem** | Prevents container tampering |
| **No host access** | `hostNetwork`, `hostPID`, and `hostIPC` are disabled |
| **No service account token** | `automountServiceAccountToken: false` |

## 📦 Usage

1. Replace the following placeholders in the manifest:
   - `your-image:latest` → your container image
   - `your-app` → your application entry point
   - `secure-config` → your ConfigMap name

2. Apply the manifest to your cluster:

```bash
kubectl apply -f secure-pod.yaml
```

3. Verify the Pod is running securely:

```bash
kubectl describe pod secure-pod-template
```

## ⚙️ CI/CD Integration (GitHub Actions)

To automate validation and deployment of your CIS-compliant Pod, add the following GitHub Actions workflow:

```yaml
# .github/workflows/deploy.yaml
name: Deploy Secure Pod

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Authenticate to cluster
      run: |
        echo "${{ secrets.KUBE_CONFIG }}" > kubeconfig
        export KUBECONFIG=kubeconfig

    - name: Validate manifest
      run: |
        kubectl apply --dry-run=client -f secure-pod.yaml

    - name: Deploy to cluster
      run: |
        kubectl apply -f secure-pod.yaml
```

> 🔐 **Note**: Store your Kubernetes config securely in GitHub Secrets as `KUBE_CONFIG`.

## 🛡️ Compliance Reference

This template aligns with the following CIS Kubernetes Benchmark controls:

- **5.2.1**: Ensure containers are not running in privileged mode
- **5.2.2–5.2.3**: Disable host PID and IPC sharing
- **5.2.5**: Prevent privilege escalation
- **5.2.8**: Drop all capabilities
- **5.2.9**: Use read-only root filesystem
- **5.2.10**: Apply seccomp profile
- **5.4.1**: Avoid automounting service account tokens

## 📚 Resources

- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/overview/)

## 🧩 Optional Enhancements

- Integrate with **Kyverno** or **OPA/Gatekeeper** for policy enforcement
- Use **NetworkPolicies** to restrict Pod communication
- Scan container images with tools like **Trivy** or **Clair**

---

Feel free to fork and customize this template to suit your workload and compliance needs.
```