# fxci-taskcluster-imaging

https://console.cloud.google.com/compute/instances?orgonly=true&project=taskcluster-imaging&supportedpurview=organizationId

## tf version requirements

This module requires terraform 1.13.4+ to work with the s3 state locking.

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth login --update-adc
tf apply
```

## TODO

- add taskcluster related IAM perms
  - see `iam_perms.png`
