# taskqueue-influxdb-metrics

author: aerickson

Logs Bitbar/Android-HW queue counts to influx.

## generating new function.zip

```
./create_zip.sh
```

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
terraform apply
```
