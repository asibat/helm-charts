# ICP Helm Charts

## Add the repo

```bash
helm repo add icp https://asibat.github.io/helm-charts
helm repo update
```

## Install the agent

```bash
# Create the token secret (token never stored in Helm release)
kubectl create namespace icp
kubectl -n icp create secret generic icp-ingest-token \
  --from-literal=ICP_INGEST_TOKEN=<your-token>

# Install
helm upgrade --install icp-agent icp/icp-agent \
  --namespace icp \
  --set-string ingestToken.existingSecret=icp-ingest-token \
  --set-string watch.namespace=<your-app-namespace> \
  --set-string watch.defaultEnvironment=production
```

## Values

| Key | Default | Description |
|-----|---------|-------------|
| `api.url` | `https://api.clarixops.dev` | ICP ingest API URL |
| `ingestToken.value` | `""` | Raw token (prefer `existingSecret` in production) |
| `ingestToken.existingSecret` | `""` | Name of a pre-created Kubernetes secret |
| `watch.namespace` | `"*"` | Namespace to watch (`*` = all) |
| `watch.defaultEnvironment` | `"production"` | Environment tag on all events |
| `watcher.enabled` | `true` | Enable K8s event watcher (pod restarts, OOM, crash loops) |
| `otelCollector.enabled` | `true` | Enable OTel Collector DaemonSet for log shipping |

Full values reference: [icp-agent/values.yaml](icp-agent/values.yaml)
