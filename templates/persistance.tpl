---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: algorand-pvc
spec:
  storageClassName: {{ .Values.persistence.storageClass }}
  accessModes:
    - {{ .Values.persistence.accessMode }}
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
