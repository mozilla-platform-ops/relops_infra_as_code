# fxci-production-level1-workers

https://console.cloud.google.com/compute/instances?orgonly=true&project=fxci-production-level1-workers&supportedpurview=organizationId

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth login --update-adc
tf apply
```

## TODO

- add IAM perms for taskcluster worker-manager
  - taskcluster-worker-manager@fxci-production-level1-workers.iam.gserviceaccount.com
    - 'Compute Admin' and 'Service Account User' permissions
  - taskcluster-worker@fxci-production-level1-workers.iam.gserviceaccount.com
    - 'Logs Writer' and 'Monitoring Metric Writer'