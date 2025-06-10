# fxci-production-level1-workers

https://console.cloud.google.com/compute/instances?orgonly=true&project=fxci-production-level1-workers&supportedpurview=organizationId

## applying

```bash
# set aws creds per https://mozilla-hub.atlassian.net/wiki/spaces/ROPS/pages/1052606564/Using+Terraform+with+AWS+SSO

export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
# e.g. export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/fxci-production-level1-workers-011de71ff168.json
gcloud auth login --update-adc
tf apply
```

## TODO

- add IAM perms for taskcluster worker-manager
  - taskcluster-worker-manager@fxci-production-level1-workers.iam.gserviceaccount.com
    - 'Compute Admin' and 'Service Account User' permissions
  - taskcluster-worker@fxci-production-level1-workers.iam.gserviceaccount.com
    - 'Logs Writer' and 'Monitoring Metric Writer'