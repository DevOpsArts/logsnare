# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within Logsnare, please send an email to security@devopsarts.io. All security vulnerabilities will be promptly addressed.

Please include the following information:
- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Steps to reproduce
- Potential impact

## Security Best Practices for Deployment

### 1. Never Commit Credentials

**DO NOT** include real credentials in values files. Always use `--set` flags or external secret management:

```bash
# Good: Pass credentials at deploy time
helm install logsnare-engine logsnare/logsnare-engine \
  --set connections.postgresql.username=$DB_USER \
  --set connections.postgresql.password=$DB_PASSWORD

# Bad: Hardcoded in values.yaml
# connections:
#   postgresql:
#     password: "mypassword123"  # NEVER DO THIS
```

### 2. Use External Secret Management

For production, use external secret management solutions:

- **Kubernetes External Secrets**: Sync secrets from AWS Secrets Manager, Azure Key Vault, GCP Secret Manager
- **HashiCorp Vault**: Use Vault Agent Injector
- **Sealed Secrets**: Encrypt secrets for Git storage

Example with External Secrets Operator:
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: logsnare-db-credentials
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-key-vault
    kind: SecretStore
  target:
    name: logsnare-engine-credentials
  data:
    - secretKey: postgresql-password
      remoteRef:
        key: logsnare-db-password
```

### 3. Enable Network Policies

Restrict pod-to-pod communication:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: logsnare-engine-policy
  namespace: logsnare
spec:
  podSelector:
    matchLabels:
      app: logsnare-engine
  policyTypes:
    - Ingress
    - Egress
  egress:
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 443  # Kubernetes API
    - to:
        - podSelector:
            matchLabels:
              app: postgresql
      ports:
        - protocol: TCP
          port: 5432
```

### 4. Use Pod Security Standards

Enable Pod Security Standards (PSS):

```yaml
# In values.yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```

### 5. RBAC - Principle of Least Privilege

The default RBAC configuration grants only necessary permissions:
- `get`, `list`, `watch` on pods (for log streaming)
- `get`, `list`, `watch` on namespaces (for namespace discovery)
- `create`, `get`, `update` on leases (for leader election)

**Do not** grant cluster-admin or overly permissive roles.

### 6. TLS/SSL for Database Connections

Always enable TLS for database connections in production:

```yaml
connections:
  postgresql:
    ssl:
      enabled: true
      mode: "verify-full"
      # Mount CA certificate
```

### 7. Image Security

- Use specific image tags, not `latest`
- Scan images for vulnerabilities
- Use signed images when available

```yaml
image:
  repository: devopsart1/logsnare-engine
  tag: "0.4.2"  # Specific version, not "latest"
  pullPolicy: IfNotPresent
```

### 8. Resource Limits

Always set resource limits to prevent DoS:

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 256Mi
```

### 9. Audit Logging

Enable Kubernetes audit logging to track API access to logsnare resources.

### 10. Regular Updates

Keep the Helm chart and container images updated to receive security patches.

## Security Features in Logsnare-Engine

1. **Input Sanitization**: All log lines are sanitized before storage
2. **No Credential Logging**: Credentials are never logged
3. **TLS Enforcement**: Cloud backends (Azure, AWS, GCP) use TLS by default
4. **Non-root Container**: Runs as non-root user by default
5. **Read-only Filesystem**: Minimal writable paths
6. **Secret References**: Credentials loaded from Kubernetes secrets, never hardcoded

## Compliance Considerations

- **GDPR**: Log data may contain PII. Implement appropriate retention policies.
- **SOC 2**: Enable audit logging and access controls.
- **HIPAA**: Ensure database backends are HIPAA-compliant if handling PHI.

## Contact

For security concerns: security@devopsarts.io
