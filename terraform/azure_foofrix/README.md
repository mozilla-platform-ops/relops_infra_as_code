# FooFrix Azure subscription

[FooFrix](https://foofrix.uc.r.appspot.com/?component=JS&suite=speedometer3)
runs agents that profile Firefox, test performance changes, build
Firefox, and produce patches. This dedicated Azure DevTest subscription lets
the team create and manage Windows VMs for runs that can last more than 24 hours.
It gives the team control over VM sizes and lifetimes, with separate costs and
access for FooFrix.

This Terraform stack manages the subscription, a resource group in Central US,
a Key Vault for AI keys and other secrets, and a managed identity for the VMs.
The team manages the VMs through `sp-foofrix-azure-devtest`. The application and
service principal are managed in `../azure_ad/foofrix.tf`.

| Identity | Access |
| --- | --- |
| Existing Relops group | Subscription Owner; Key Vault Administrator |
| `sp-foofrix-azure-devtest` | Subscription Contributor; Key Vault Secrets Officer |
| `id-foofrix-worker` | Read secrets in the FooFrix vault |

The provisioning service uses a tenant ID, client ID, and client secret to
access Azure. The client secret is managed outside Terraform and stored in
1Password. VMs use `id-foofrix-worker` to read secrets from Key Vault.

FooFrix uses the same Mozilla billing profile and invoice section as fuzzing.
The daily Actual Cost, Amortized Cost, and FOCUS exports in
`../azure_billing/finops.tf` include its costs in
`safinopsdata/cost-management`. Filter by the FooFrix subscription ID to report
its costs.

Related issue: [RELOPS-2548](https://mozilla-hub.atlassian.net/browse/RELOPS-2548).
