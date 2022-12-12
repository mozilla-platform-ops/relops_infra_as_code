# bitbar-devicepool terraform

author: aerickson

Runs 3 small Google compute instances.

## applying

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=~/.gcp_credentials/BLAH
gcloud auth application-default login
tf apply
```

## replacing nodes

```bash
# double check correct key in terraform.tfvars
# currently uses aerickson

# get list of resources
tf state list

# plan and apply while replacing specific resources
tf plan -replace='google_compute_instance.vm_instance[2]' -replace='google_compute_disk.vm_disk[2]'
# then `tf apply` with same args
```

## troubleshooting

### can't ssh to host

If keys are messed up, GCP can inject a key.

`gcloud compute ssh --zone "us-west1-b" "bitbar-devicepool-2"  --project "bitbar-devicepool"`


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
