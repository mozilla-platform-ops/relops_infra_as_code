# fxci-production-level3-workers

https://console.cloud.google.com/compute/instances?orgonly=true&project=fxci-production-level3-workers&supportedpurview=organizationId

## applying

```bash
# set aws creds per https://mozilla-hub.atlassian.net/wiki/spaces/ROPS/pages/1052606564/Using+Terraform+with+AWS+SSO

gcloud auth login --update-adc
tf apply
```

## TODO

- add IAM perms for taskcluster worker-manager
  - taskcluster-worker-manager@fxci-production-level3-workers.iam.gserviceaccount.com
    - 'Compute Admin' and 'Service Account User' permissions
  - taskcluster-worker@fxci-production-level3-workers.iam.gserviceaccount.com
    - 'Logs Writer' and 'Monitoring Metric Writer'