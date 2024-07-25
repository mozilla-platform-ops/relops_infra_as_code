# fxci-production-level3-workers

https://console.cloud.google.com/compute/instances?orgonly=true&project=fxci-production-level3-workers&supportedpurview=organizationId

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth login --update-adc
tf apply
```
