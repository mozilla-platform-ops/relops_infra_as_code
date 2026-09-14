# FooFrix Azure subscription

[FooFrix](https://foofrix.uc.r.appspot.com/?component=JS&suite=speedometer3)
runs agents that profile Firefox, test performance changes, build Firefox,
and produce patches. Its launcher, scheduler, queue, results, and dashboard
remain in GCP. This dedicated Azure DevTest subscription gives the GCP launcher
a target for Windows testing. It can create VMs from an image, run tests, and
remove the VMs when finished, including runs that last more than 24 hours.
Windows workers use the existing GCS queue and report results to
`gs://foofrix-findings`.

The harness source and image provisioning scripts are in
[dpalmeiro/foofrix](https://github.com/dpalmeiro/foofrix).

This Terraform stack manages the subscription, a resource group in Central US,
a Key Vault available for Windows worker secrets, and a managed identity for the VMs.
The `foofrix` Compute Gallery stores VM image versions. A private `artifacts`
Blob Storage container holds Azure build and image files in Standard LRS storage.
The GCP launcher manages the VMs through `sp-foofrix-azure-devtest`. The application and
service principal are managed in `../azure_ad/foofrix.tf`.

| Identity | Access |
| --- | --- |
| Existing Relops group | Subscription Owner; Key Vault Administrator; blob read/write |
| `sp-foofrix-azure-devtest` | Subscription Contributor; Key Vault Secrets Officer; blob read/write |
| `id-foofrix-worker` | Read vault secrets; blob read/write |

The GCP launcher uses a tenant ID, client ID, and client secret to
access Azure. The client secret is managed outside Terraform and stored in
1Password. VMs can use `id-foofrix-worker` to read secrets from Key Vault.
Access to the GCS queue and results bucket requires separate Google credentials.
Blob access uses these identities through the Storage Blob Data Contributor
role on the `artifacts` container. The provisioning service can manage gallery
images through its subscription Contributor role.

FooFrix uses the same Mozilla billing profile and invoice section as fuzzing.
The daily Actual Cost, Amortized Cost, and FOCUS exports in
`../azure_billing/finops.tf` include its costs in
`safinopsdata/cost-management`. Filter by the FooFrix subscription ID to report
its costs.

Related issue: [RELOPS-2548](https://mozilla-hub.atlassian.net/browse/RELOPS-2548).
