{{/*
Implement fsGroup DR-D1123-136
*/}}
{{- define "eric-enmsg-fmx-rabbitmq-server.fsGroup.coordinated" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.fsGroup -}}
      {{- if not (kindIs "invalid" .Values.global.fsGroup.manual) -}}
        {{- if .Values.global.fsGroup.manual | int64 | toString | trimAll " " | mustRegexMatch "^[0-9]+$" }}
          {{- .Values.global.fsGroup.manual | int64 | toString | trimAll " " }}
        {{- else }}
          {{- fail "global.fsGroup.manual shall be a positive integer if given" }}
        {{- end }}
      {{- else -}}
        {{- if eq (.Values.global.fsGroup.namespace | toString) "true" -}}
          # The 'default' defined in the Security Policy will be used.
        {{- else -}}
          {{ .Values.fsGroup.coordinated }}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{ .Values.fsGroup.coordinated }}
    {{- end -}}
  {{- else -}}
    {{ .Values.fsGroup.coordinated }}
  {{- end -}}
{{- end -}}