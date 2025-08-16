package kubernetes.admission

import data.kubernetes.namespaces

# Deny privileged containers
deny[msg] {
    input.kind == "Pod"
    input.spec.containers[_].securityContext.privileged
    msg := "Privileged containers are not allowed"
}

# Deny containers running as root
deny[msg] {
    input.kind == "Pod"
    input.spec.containers[_].securityContext.runAsUser == 0
    msg := "Containers must not run as root (UID 0)"
}

# Deny containers without runAsNonRoot
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.securityContext.runAsNonRoot
    msg := sprintf("Container %v must set runAsNonRoot to true", [container.name])
}

# Deny containers with allowPrivilegeEscalation
deny[msg] {
    input.kind == "Pod"
    input.spec.containers[_].securityContext.allowPrivilegeEscalation
    msg := "Privilege escalation is not allowed"
}

# Deny containers without readOnlyRootFilesystem
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem
    msg := sprintf("Container %v must have readOnlyRootFilesystem set to true", [container.name])
}

# Deny containers with ALL capabilities
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    cap := container.securityContext.capabilities.drop[_]
    cap == "ALL"
    msg := sprintf("Container %v must drop ALL capabilities", [container.name])
}

# Deny containers without seccomp profile
deny[msg] {
    input.kind == "Pod"
    not input.spec.securityContext.seccompProfile.type
    msg := "Pod must specify a seccomp profile"
}

# Deny containers with host network access
deny[msg] {
    input.kind == "Pod"
    input.spec.hostNetwork
    msg := "Host network access is not allowed"
}

# Deny containers with host PID access
deny[msg] {
    input.kind == "Pod"
    input.spec.hostPID
    msg := "Host PID access is not allowed"
}

# Deny containers with host IPC access
deny[msg] {
    input.kind == "Pod"
    input.spec.hostIPC
    msg := "Host IPC access is not allowed"
}

# Deny containers without resource limits
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.resources.limits
    msg := sprintf("Container %v must specify resource limits", [container.name])
}

# Deny containers without resource requests
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.resources.requests
    msg := sprintf("Container %v must specify resource requests", [container.name])
}

# Deny containers with excessive resource limits
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    limits := container.resources.limits
    limits.memory
    parse_quantity(limits.memory) > parse_quantity("2Gi")
    msg := sprintf("Container %v memory limit exceeds 2Gi", [container.name])
}

# Deny containers with excessive CPU limits
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    limits := container.resources.limits
    limits.cpu
    parse_quantity(limits.cpu) > parse_quantity("2000m")
    msg := sprintf("Container %v CPU limit exceeds 2000m", [container.name])
}

# Deny containers without liveness probe
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.livenessProbe
    msg := sprintf("Container %v must have a liveness probe", [container.name])
}

# Deny containers without readiness probe
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.readinessProbe
    msg := sprintf("Container %v must have a readiness probe", [container.name])
}

# Deny containers without security context
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.securityContext
    msg := sprintf("Container %v must have a security context", [container.name])
}

# Deny pods without pod security context
deny[msg] {
    input.kind == "Pod"
    not input.spec.securityContext
    msg := "Pod must have a pod-level security context"
}

# Deny containers with latest tag
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("Container %v must not use 'latest' tag", [container.name])
}

# Deny containers without image pull policy
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.imagePullPolicy
    msg := sprintf("Container %v must specify imagePullPolicy", [container.name])
}

# Deny containers with Always image pull policy in production
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    container.imagePullPolicy == "Always"
    namespace := input.metadata.namespace
    namespace == "production"
    msg := sprintf("Container %v must not use Always imagePullPolicy in production", [container.name])
}

# Deny containers without proper labels
deny[msg] {
    input.kind == "Pod"
    labels := input.metadata.labels
    not labels.app
    msg := "Pod must have 'app' label"
}

# Deny containers without compliance labels
deny[msg] {
    input.kind == "Pod"
    labels := input.metadata.labels
    not labels.compliance
    msg := "Pod must have 'compliance' label"
}

# Deny containers without environment labels
deny[msg] {
    input.kind == "Pod"
    labels := input.metadata.labels
    not labels.environment
    msg := "Pod must have 'environment' label"
}

# Deny containers with automount service account token
deny[msg] {
    input.kind == "Pod"
    input.spec.automountServiceAccountToken
    msg := "Automount service account token is not allowed"
}

# Deny containers with share process namespace
deny[msg] {
    input.kind == "Pod"
    input.spec.shareProcessNamespace
    msg := "Process namespace sharing is not allowed"
}

# Deny containers without termination grace period
deny[msg] {
    input.kind == "Pod"
    not input.spec.terminationGracePeriodSeconds
    msg := "Pod must specify termination grace period"
}

# Deny containers with excessive termination grace period
deny[msg] {
    input.kind == "Pod"
    grace_period := input.spec.terminationGracePeriodSeconds
    grace_period > 60
    msg := "Termination grace period must not exceed 60 seconds"
}

# Deny containers without proper volume mounts
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    volume_mounts := container.volumeMounts
    not volume_mounts
    msg := sprintf("Container %v must have volume mounts for configuration", [container.name])
}

# Deny containers with host path volumes
deny[msg] {
    input.kind == "Pod"
    volume := input.spec.volumes[_]
    volume.hostPath
    msg := "Host path volumes are not allowed"
}

# Deny containers with empty dir volumes without size limit
deny[msg] {
    input.kind == "Pod"
    volume := input.spec.volumes[_]
    volume.emptyDir
    not volume.emptyDir.sizeLimit
    msg := "Empty dir volumes must specify size limit"
}

# Deny containers with excessive empty dir size
deny[msg] {
    input.kind == "Pod"
    volume := input.spec.volumes[_]
    volume.emptyDir
    volume.emptyDir.sizeLimit
    parse_quantity(volume.emptyDir.sizeLimit) > parse_quantity("1Gi")
    msg := "Empty dir volume size limit must not exceed 1Gi"
}

# Deny containers without proper port configuration
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    ports := container.ports
    not ports
    msg := sprintf("Container %v must specify ports", [container.name])
}

# Deny containers with UDP ports (unless explicitly allowed)
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    port := container.ports[_]
    port.protocol == "UDP"
    not port.name
    msg := sprintf("Container %v UDP port must have a name", [container.name])
}

# Deny containers without proper environment variables
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    env := container.env
    not env
    msg := sprintf("Container %v must have environment variables", [container.name])
}

# Deny containers with sensitive environment variables
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    env := container.env[_]
    env.name == "SECRET_KEY"
    not env.valueFrom.secretKeyRef
    msg := sprintf("Container %v must use secretKeyRef for SECRET_KEY", [container.name])
}

# Deny containers without proper lifecycle hooks
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not container.lifecycle
    msg := sprintf("Container %v must have lifecycle hooks", [container.name])
}

# Deny containers without preStop hook
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    lifecycle := container.lifecycle
    not lifecycle.preStop
    msg := sprintf("Container %v must have preStop lifecycle hook", [container.name])
}

# Deny containers with excessive startup probe failure threshold
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    startup_probe := container.startupProbe
    startup_probe
    startup_probe.failureThreshold > 30
    msg := sprintf("Container %v startup probe failure threshold must not exceed 30", [container.name])
}

# Deny containers with excessive liveness probe failure threshold
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    liveness_probe := container.livenessProbe
    liveness_probe
    liveness_probe.failureThreshold > 5
    msg := sprintf("Container %v liveness probe failure threshold must not exceed 5", [container.name])
}

# Deny containers with excessive readiness probe failure threshold
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    readiness_probe := container.readinessProbe
    readiness_probe
    readiness_probe.failureThreshold > 5
    msg := sprintf("Container %v readiness probe failure threshold must not exceed 5", [container.name])
}

# Deny containers without proper annotations
deny[msg] {
    input.kind == "Pod"
    annotations := input.metadata.annotations
    not annotations["security.kubernetes.io/psp"]
    msg := "Pod must have Pod Security Policy annotation"
}

# Deny containers without prometheus annotations
deny[msg] {
    input.kind == "Pod"
    annotations := input.metadata.annotations
    not annotations["prometheus.io/scrape"]
    msg := "Pod must have Prometheus scrape annotation"
}

# Deny containers with istio injection in production
deny[msg] {
    input.kind == "Pod"
    annotations := input.metadata.annotations
    annotations["sidecar.istio.io/inject"] == "true"
    namespace := input.metadata.namespace
    namespace == "production"
    msg := "Istio sidecar injection is not allowed in production"
}

# Helper function to parse Kubernetes quantity
parse_quantity(quantity) = result {
    # This is a simplified parser - in production, use proper Kubernetes quantity parsing
    endswith(quantity, "Gi")
    result := to_number(replace(quantity, "Gi", "")) * 1024 * 1024 * 1024
}

parse_quantity(quantity) = result {
    endswith(quantity, "Mi")
    result := to_number(replace(quantity, "Mi", "")) * 1024 * 1024
}

parse_quantity(quantity) = result {
    endswith(quantity, "Ki")
    result := to_number(replace(quantity, "Ki", "")) * 1024
}

parse_quantity(quantity) = result {
    endswith(quantity, "m")
    result := to_number(replace(quantity, "m", "")) / 1000
}

parse_quantity(quantity) = result {
    not endswith(quantity, "Gi")
    not endswith(quantity, "Mi")
    not endswith(quantity, "Ki")
    not endswith(quantity, "m")
    result := to_number(quantity)
} 