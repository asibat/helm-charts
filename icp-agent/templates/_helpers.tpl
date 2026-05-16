{{- define "icp-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "icp-agent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "icp-agent.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "icp-agent.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/part-of: "icp"
{{- end -}}

{{- define "icp-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "icp-agent.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{- define "icp-agent.secretName" -}}
{{- if .Values.ingestToken.existingSecret -}}
{{- .Values.ingestToken.existingSecret -}}
{{- else -}}
{{- printf "%s-ingest" (include "icp-agent.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "icp-agent.watcherServiceAccountName" -}}
{{- if .Values.watcher.serviceAccount.name -}}
{{- .Values.watcher.serviceAccount.name -}}
{{- else -}}
{{- printf "%s-watcher" (include "icp-agent.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "icp-agent.otelServiceAccountName" -}}
{{- if .Values.otelCollector.serviceAccount.name -}}
{{- .Values.otelCollector.serviceAccount.name -}}
{{- else -}}
{{- printf "%s-otel" (include "icp-agent.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "icp-agent.apiUrl" -}}
{{- trimSuffix "/" .Values.api.url -}}
{{- end -}}

{{- define "icp-agent.podLogInclude" -}}
{{- if or (eq .Values.watch.namespace "*") (eq .Values.watch.namespace "") -}}
/var/log/pods/*_*/*/*.log
{{- else -}}
/var/log/pods/{{ .Values.watch.namespace }}_*/*/*.log
{{- end -}}
{{- end -}}
