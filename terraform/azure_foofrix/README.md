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
Terraform manages the `foofrix` Compute Gallery and its `win11_64_24h2` image
definition. It uses the existing FXCI Windows 11 24H2 properties: Windows, x64,
Hyper-V V2, generalized, and `MicrosoftWindowsDesktop/Windows-11/win11-24h2-avd`.
The worker-images workflow publishes image versions. A private `artifacts`
Blob Storage container holds Azure build and image files in Standard LRS storage.
The GCP launcher manages the VMs through `sp-foofrix-azure-devtest`. The application and
service principal are managed in `../azure_ad/foofrix.tf`.

| Identity | Access |
| --- | --- |
| Existing Relops group | Subscription Owner; Key Vault Administrator; blob read/write |
| `sp-foofrix-azure-devtest` | Subscription Contributor; Key Vault Secrets Officer; blob read/write |
| `id-foofrix-worker` | Read vault secrets; blob read/write |
| Platform Performance | Subscription Contributor; Key Vault Secrets Officer; blob read/write |
| `sp-foofrix-image-build` | Contributor on the build resource group and gallery; blob read; attach the build identity |
| `id-foofrix-image-build` | Blob read during image creation |

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

## Image builds and access setup

Apply `azure_ad` before this stack. Create the subscription with a targeted plan
for `azurerm_subscription.foofrix`, then run a full plan and apply.

The build application uses GitHub OIDC with this exact subject:
`repo:mozilla-platform-ops/worker-images:environment:foofrix-image-build`.
RELOPS-2570 must create and protect that dedicated GitHub environment and use it
in the authorized FooFrix workflow before image builds start. This subject
permits jobs that use that environment; it does not identify a workflow file.
Use environment deployment rules and the team authorization check to control access.
The workflow needs `id-token: write` and audience `api://AzureADTokenExchange`.
No image-build client secret is needed.

Configure Packer to use the existing `image_build_resource_group` output for
temporary resources. Publish to `image_gallery_name` in
`image_gallery_resource_group`, using the definition from
`windows_image_definition_id`. The workflow logs in with `image_build_client_id`.
Attach `image_build_identity_id` to the temporary VM. The guest bootstrap must
use that managed identity to authenticate artifact downloads, with
`image_build_identity_client_id` to select it. The GitHub login does not provide
credentials inside the VM. Both build identities have read access to `artifacts`.

Platform Performance starts with Denis Palmeiro and Justin Link. Add Frank Doty,
Andrew Creskey, Jamie Nicol, Marc Leclair, Markus Stange, and Sky Ning after their
Entra accounts are created. Deliver Denis's temporary password through the
approved private process. He must change it and complete MFA enrollment.
Do not put credentials in Terraform or the PR.

Perf owns VM creation, deletion, and the FooFrix harness and GCP integration.
RelOps supplies the Azure resources and image-build path. RELOPS-2570 covers
Windows tooling, profiling support, startup, and image validation.

The GCS authentication design still needs agreement with Perf. If Azure managed
identity to Google Workload Identity Federation is selected, add the Entra
audience application in `azure_ad` and the Google trust and bucket grants in GCP.
Queue and state access to `foofrix-findings` in project `foofrix` needs reads,
updates, and deletes as well as uploads. Test results remain in GCS.
