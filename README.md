<p align="center">
  <img src="logo-horizontal.svg" alt="Logsnare" width="400">
</p>

<p align="center">
  <em>The only Kubernetes log agent with intelligent error context capture, rule-based alerting, and 9 pluggable storage backends — from PostgreSQL to Azure, AWS, and GCP cloud logging.</em>
</p>

[![Helm](https://img.shields.io/badge/Helm-v3-blue.svg)](https://helm.sh)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.24%2B-blue.svg)](https://kubernetes.io)

Official Helm charts for deploying **Logsnare-Engine** - a scalable Kubernetes log monitoring agent with intelligent error detection, pattern-based alerting, and multi-backend storage support.

## Overview

Logsnare-Engine monitors pod logs across Kubernetes namespaces and captures contextual log data when errors are detected. It supports rule-based alerting (email, Slack, Teams, PagerDuty, webhooks) and multiple storage backends including PostgreSQL, MongoDB, MySQL, Elasticsearch, InfluxDB, Azure Log Analytics, AWS CloudWatch, and GCP Cloud Logging.

## Quick Start

### Option 1: Install from GitHub Repository

```bash
# Clone the repository
git clone https://github.com/DevOpsArts/logsnare.git
cd logsnare

# Install with default settings (File Storage)
helm install logsnare-engine ./charts/logsnare-engine \
  --namespace logsnare \
  --create-namespace
```

### Install with PostgreSQL

```bash
helm install logsnare-engine ./charts/logsnare-engine \
  --namespace logsnare \
  --create-namespace \
  --set storage.type=postgresql \
  --set connections.postgresql.enabled=true \
  --set connections.postgresql.host=postgresql.database.svc.cluster.local \
  --set connections.postgresql.username=logsnare \
  --set connections.postgresql.password=<REPLACE_ME>
```

### Install with Azure Log Analytics

```bash
helm install logsnare-engine ./charts/logsnare-engine \
  --namespace logsnare \
  --create-namespace \
  --set storage.type=azure \
  --set connections.azure.enabled=true \
  --set connections.azure.workspaceId=<REPLACE_ME> \
  --set connections.azure.sharedKey=<REPLACE_ME> \
  --set connections.azure.logType=LogsnareK8sLogs
```

## Supported Storage Backends

| Backend | Type Value | Description |
|---------|------------|-------------|
| File | `file` | Local file storage (default) |
| PostgreSQL | `postgresql` | Relational database |
| MongoDB | `mongodb` | Document database |
| MySQL | `mysql` | Relational database |
| InfluxDB | `influxdb` | Time-series database |
| Elasticsearch | `elasticsearch` | Search and analytics |
| Azure Log Analytics | `azure` | Azure cloud logging |
| AWS CloudWatch | `aws` | AWS cloud logging |
| GCP Cloud Logging | `gcp` | Google Cloud logging |

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `devopsart1/logsnare-engine` |
| `image.tag` | Image tag | `0.4.2` |
| `storage.type` | Storage backend type | `file` |
| `monitoring.namespaces` | Namespaces to monitor | `["default", "kube-system"]` |
| `scalability.maxWorkers` | Max concurrent pod monitors | `20` |
| `leaderElection.enabled` | Enable HA leader election | `false` |

### Full Configuration

See [values.yaml](charts/logsnare-engine/values.yaml) for all available configuration options.

## Capacity Planning

| Pods | Max Workers | Memory Request | Memory Limit | Replicas |
|------|-------------|----------------|--------------|----------|
| 25   | 30          | 128Mi          | 256Mi        | 1        |
| 50   | 60          | 256Mi          | 512Mi        | 1        |
| 100  | 120         | 512Mi          | 1Gi          | 1        |
| 250  | 100         | 512Mi          | 1Gi          | 3 (HA)   |
| 500  | 125         | 768Mi          | 1.5Gi        | 5 (HA)   |

## High Availability

For production deployments, enable leader election:

```bash
helm install logsnare-engine ./charts/logsnare-engine \
  --namespace logsnare \
  --create-namespace \
  --set replicaCount=3 \
  --set leaderElection.enabled=true \
  --set storage.type=postgresql \
  --set connections.postgresql.enabled=true \
  --set connections.postgresql.host=postgresql.database.svc.cluster.local \
  --set connections.postgresql.username=logsnare \
  --set connections.postgresql.password=<REPLACE_ME>
```

## Uninstall

```bash
helm uninstall logsnare-engine -n logsnare
kubectl delete namespace logsnare
```

## Documentation

📖 **[Wiki Documentation](https://github.com/devopsarts/logsnare/wiki)** - Complete guides and references

- [Installation Guide](https://github.com/devopsarts/logsnare/wiki/Installation-Guide) - Step-by-step installation for all storage backends
- [Configuration Reference](https://github.com/devopsarts/logsnare/wiki/Configuration-Reference) - All Helm chart values explained
- [Storage Backends](https://github.com/devopsarts/logsnare/wiki/Storage-Backends) - Detailed setup for each storage option
- [Capacity Planning](https://github.com/devopsarts/logsnare/wiki/Capacity-Planning) - Resource sizing guidelines
- [Troubleshooting](https://github.com/devopsarts/logsnare/wiki/Troubleshooting) - Common issues and solutions

## Requirements

- Kubernetes 1.24+
- Helm 3.0+
- RBAC enabled cluster
- (Optional) Storage backend (PostgreSQL, MongoDB, etc.)

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- **Wiki**: [https://github.com/devopsarts/logsnare/wiki](https://github.com/devopsarts/logsnare/wiki)
- **Issues**: [https://github.com/devopsarts/logsnare/issues](https://github.com/devopsarts/logsnare/issues)
