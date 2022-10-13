# bitbar-devicepool terraform

author: aerickson

Runs 3 small Google compute instances.

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth application-default login
tf apply
```

## troubleshooting

### `oauth2: cannot fetch token` tf errors

```
│ Error: Error when reading or editing ComputeAddress "bitbar-devicepool/us-west1/devicepool-ip-2": Get "https://compute.googleapis.com/compute/v1/projects/bitbar-devicepool/regions/us-west1/addresses/devicepool-ip-2?alt=json": oauth2: cannot fetch token: 400 Bad Request
│ Response: {
│   "error": "invalid_grant",
│   "error_description": "reauth related error (invalid_rapt)",
│   "error_uri": "https://support.google.com/a/answer/9368756",
│   "error_subtype": "invalid_rapt"
│ }
```

then you should run `gcloud auth application-default login`.