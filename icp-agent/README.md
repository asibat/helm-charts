# ICP Agent Helm Chart

Installs the Kubernetes-side ICP agent for EKS and other Kubernetes clusters:

- OTel Collector DaemonSet tails `/var/log/pods` and forwards logs to `/ingest/logs/otlp`.
- Watcher DaemonSet emits pod restart, crash loop, and OOM events to `/ingest/runtime`.
- One ingest token is wired into both components through a Kubernetes Secret.

## Quick Install

```bash
export ICP_INGEST_URL="https://api.clarixops.dev"
export ICP_INGEST_TOKEN="<token from Clarix Settings -> Tokens>"

pnpm eks:install-agent
```

By default the chart watches all namespaces and tags runtime events with
`production` when no supported environment label is present.

## Direct Helm Install

```bash
helm upgrade --install icp-agent ./infra/helm/icp-agent \
  --namespace icp \
  --create-namespace \
  --set-string api.url="https://api.clarixops.dev" \
  --set-string ingestToken.value="<token>" \
  --set-string watch.namespace="*" \
  --set-string watch.defaultEnvironment="production"
```

For GitOps, create the Secret yourself and reference it:

```bash
kubectl -n icp create secret generic icp-ingest \
  --from-literal=ICP_INGEST_TOKEN="<token>"

helm upgrade --install icp-agent ./infra/helm/icp-agent \
  --namespace icp \
  --create-namespace \
  --set-string api.url="https://api.clarixops.dev" \
  --set-string ingestToken.existingSecret="icp-ingest"
```

## EKS Notes

The chart only needs read-only pod access:

- `pods: get/list/watch` for the watcher
- `pods,namespaces: get/list/watch` for the OTel Collector metadata path

The watcher runs as a DaemonSet but filters by `spec.nodeName`, so each pod only
observes workloads on its own node and does not duplicate runtime events across
nodes.

## Common Values

| Value | Default | Purpose |
|---|---|---|
| `api.url` | `https://api.clarixops.dev` | ICP ingest API base URL |
| `ingestToken.value` | empty | Creates a Secret from this token |
| `ingestToken.existingSecret` | empty | Use an existing Secret instead |
| `watch.namespace` | `*` | `*` for all namespaces, or a namespace name |
| `watch.defaultEnvironment` | `production` | Fallback environment for watcher events |
| `watcher.image.repository` | `ghcr.io/asibat/incident-context-watcher` | Watcher image repository |
| `otelCollector.image.tag` | `0.113.0` | OTel Collector contrib image tag |

If you publish the watcher image under a different registry, pass it through the
script:

```bash
pnpm eks:install-agent --set-string watcher.image.repository="<registry>/watcher" --set-string watcher.image.tag="<tag>"
```

## Verify

```bash
kubectl -n icp rollout status daemonset/icp-agent-watcher
kubectl -n icp rollout status daemonset/icp-agent-otel

kubectl -n icp logs -l app.kubernetes.io/component=watcher --tail=50
kubectl -n icp logs -l app.kubernetes.io/component=otel-collector --tail=50
```
