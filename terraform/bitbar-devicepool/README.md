# bitbar-devicepool terraform

author: aerickson

Runs 3 small Google compute instances.

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth application-default login
tf apply
```
