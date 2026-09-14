# FooFrix Azure subscription

This stack implements the subscription plan in the
[September 11 meeting notes](https://mozilla-hub.atlassian.net/browse/RELOPS-2548?focusedCommentId=1727342).
It follows `azure_fuzzing`: `azure_ad` owns the application and service principal;
this stack owns the subscription and Azure resources.

FooFrix uses the same billing profile (`GRUW-TLBL-BG7-PGB`) and invoice section
(`VVEC-AWWS-PJA-PGB`) as fuzzing. The existing daily Actual Cost, Amortized Cost,
and FOCUS exports in `azure_billing/finops.tf` cover these scopes without
subscription filters. They write to `safinopsdata/cost-management`. No separate
export is needed. After deployment and billing data arrival, filter by the
FooFrix subscription ID to report its costs.

The draft uses Central US and gives Denis Palmeiro access. Confirm the region
and full Perf access list before deployment. Perf will create and remove its
VMs. This stack does not create a Taskcluster pool.

| Identity | Access |
| --- | --- |
| Relops group | Subscription Owner; Key Vault Administrator |
| Perf members in `main.tf` | Subscription Contributor; Key Vault Secrets Officer |
| `sp-foofrix-azure-devtest` | Contributor on the FooFrix subscription |
| `id-foofrix-worker` | Read secrets in the FooFrix vault |

Attach `id-foofrix-worker` to each FooFrix VM. Use its client ID to select it
when the agent reads Key Vault. Perf members can add AI keys through Key Vault.
Keep secret values out of Terraform, VM images, and startup scripts. Contributor
access lets the provisioner attach this identity without permission to create
role assignments. It therefore also permits indirect access to these secrets
through a VM that it controls.

## Initial deployment

The subscription must exist before the default Azure provider can use it.
Use two stages for the first deployment. The `billing` provider uses the existing
FXCI subscription only to call the subscription creation API.

1. In `azure_ad`, review and apply the FooFrix application and service
   principal. It has no credential yet. Add GCP federation after the service
   account unique ID is known.
2. In this directory, initialize the backend and review the subscription plan:

   ```sh
   export AWS_PROFILE=AdministratorAccess-961225894672
   terraform init
   terraform plan -target=azurerm_subscription.foofrix -out=subscription.tfplan
   ```

3. Apply the reviewed subscription plan. Then review a full plan:

   ```sh
   terraform apply subscription.tfplan
   terraform plan -out=foofrix.tfplan
   ```

4. Apply the reviewed full plan. Use full plans for later changes.
   Give Perf the subscription ID, provisioner client ID, worker identity ID,
   worker identity client ID, and vault URI from `terraform output`.

## GCP authentication

For GCP to Azure, add a federated credential to the FooFrix application once
Perf supplies the GCP service account's numeric unique ID. Use issuer
`https://accounts.google.com` and audience `api://AzureADTokenExchange`.
See the [Microsoft GCP federation guide](https://learn.microsoft.com/entra/workload-id/workload-identity-federation-google-cloud).

For Azure to GCS, use the worker managed identity with Google Workload Identity
Federation. This still needs the GCP project, results bucket, and required object
operations. Configure the Entra audience application, Google trust provider,
identity restriction, and bucket access after those values are known. These
resources are not part of this draft. See the
[Google Azure federation guide](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds).

## Windows VM and image work

Start with one regular VM. Do not configure Spot eviction or a one-hour shutdown.
The first run must last at least 24 hours and complete a Firefox build and a
FooFrix test. Perf can then increase the count to two or three.

For a GPU proof of concept, evaluate `Standard_NV18ads_A10_v5` (18 vCPUs,
220 GiB RAM, half an A10 GPU). If the test needs a full GPU, evaluate
`Standard_NV36ads_A10_v5` (36 vCPUs, 440 GiB RAM, one A10). Confirm regional
availability and quota in the new subscription. These are candidates, pending
the harness requirements. See the [Azure size table](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nvadsa10v5-series).
Start with a 1 TiB persistent build disk and measure peak use. Temporary storage
must not hold the only copy of source changes or results.

Provisioning needs Azure CLI or an Azure SDK, a VNet and subnet, a restricted
remote access rule, a Windows image version, persistent disks, and the worker
identity. Select the exact image and access method after repository inspection.

`worker-images` has the Packer and Azure Compute Gallery build path. Its Windows
configs select Puppet roles and Pester tests. Its GitHub workflows also check
`.github/relsre.json`; repository access alone does not permit a build.

Before adding a FooFrix image, inspect the harness to determine whether it needs
a prebuilt Chromium release or a Chromium source build with release options.
Confirm the version, build flags, toolchain, GPU driver, expected paths, and
update process. Add a separate image config and checks for Firefox builds,
Chromium startup, GPU use, and long VM lifetime. Confirm that Taskcluster startup
and shutdown services cannot terminate the standalone VM. Arrange gallery read
access from the FooFrix subscription and build access for the named Perf users.

Any later use in a production Firefox CI pool must pass all tier 1 tasks from
the latest autoland decision task. A new tier 1 regression blocks deployment.

## Checks

```sh
terraform init -backend=false
terraform fmt -check
terraform validate
```
