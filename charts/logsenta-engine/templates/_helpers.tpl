{{/*
Expand the name of the chart.
*/}}
{{- define "logsenta.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "logsenta.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "logsenta.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "logsenta.labels" -}}
helm.sh/chart: {{ include "logsenta.chart" . }}
{{ include "logsenta.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "logsenta.selectorLabels" -}}
app.kubernetes.io/name: {{ include "logsenta.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "logsenta.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "logsenta.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "logsenta.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the namespace name
*/}}
{{- define "logsenta.namespace" -}}
{{- if .Values.namespace.name }}
{{- .Values.namespace.name }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Create secret name for database credentials
*/}}
{{- define "logsenta.secretName" -}}
{{- printf "%s-credentials" (include "logsenta.fullname" .) }}
{{- end }}

{{/*
Create configmap name
*/}}
{{- define "logsenta.configmapName" -}}
{{- printf "%s-config" (include "logsenta.fullname" .) }}
{{- end }}

{{/*
Check if any database connection or alerting is enabled (requires secrets)
*/}}
{{- define "logsenta.secretsEnabled" -}}
{{- if or .Values.connections.mongodb.enabled .Values.connections.mysql.enabled .Values.connections.postgresql.enabled .Values.connections.influxdb.enabled .Values.connections.elasticsearch.enabled .Values.connections.azure.enabled .Values.connections.gcp.enabled .Values.connections.aws.enabled .Values.alerting.enabled }}
{{- true }}
{{- end }}
{{- end }}
