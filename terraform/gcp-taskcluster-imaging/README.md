# fxci-taskcluster-imaging

https://console.cloud.google.com/compute/instances?orgonly=true&project=taskcluster-imaging&supportedpurview=organizationId

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth login --update-adc
tf apply
```
