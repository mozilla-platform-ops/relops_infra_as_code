# taskqueue-influxdb-metrics

author: aerickson

Logs Bitbar/Android-HW queue counts to influx.

## applying

```bash
# function.zip is not checked in to save space.
./create_zip.sh
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
terraform apply
```
