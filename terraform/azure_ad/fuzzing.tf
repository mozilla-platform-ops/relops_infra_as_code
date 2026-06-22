# Entra ID applications related to the Fuzzing Azure DevTest Subscription. RELOPS-2440.
#
# Contributor role assignments on the subscription live in the azure_fuzzing module
# (the Azure resources), which looks these service principals up by display name.
#
# clauditor identities back a token-exchange chain:
#   * sp-clauditor-build    CI builds in GitHub Actions -> Azure (GitHub OIDC)
#   * sp-clauditor-audience audience-only app for Azure -> GCP/Anthropic token exchange
#   * sp-clauditor-run      clauditor-run on GCP -> Azure (GCP service account OIDC)
locals {
  clauditor_apps = {
    build    = { name = "sp-clauditor-build", notes = "CI build identity for MozillaSecurity/clauditor (GitHub Actions OIDC). RELOPS-2440." }
    audience = { name = "sp-clauditor-audience", notes = "Audience-only app for Azure -> GCP/Anthropic token exchange. RELOPS-2440." }
    run      = { name = "sp-clauditor-run", notes = "Run identity for clauditor-run on GCP (GCP service account OIDC). RELOPS-2440." }
  }

  # Federated credentials keyed by app. build trusts GitHub Actions on master + PRs;
  # run trusts the clauditor-run GCP service account. audience has none.
  clauditor_federated_credentials = {
    build_master = {
      app          = "build"
      display_name = "github-actions-master"
      description  = "GitHub Actions OIDC for master branch workflows in MozillaSecurity/clauditor"
      issuer       = "https://token.actions.githubusercontent.com"
      subject      = "repo:MozillaSecurity/clauditor:ref:refs/heads/master"
    }
    build_pr = {
      app          = "build"
      display_name = "github-actions-pr"
      description  = "GitHub Actions OIDC for pull_request workflows in MozillaSecurity/clauditor"
      issuer       = "https://token.actions.githubusercontent.com"
      subject      = "repo:MozillaSecurity/clauditor:pull_request"
    }
    run_gcp = {
      app          = "run"
      display_name = "gcp-clauditor-run"
      description  = "GCP service account OIDC for the clauditor-run workload"
      issuer       = "https://accounts.google.com"
      subject      = var.clauditor_run_gcp_sa_subject
    }
  }
}

resource "azuread_application" "fuzzing_azure_devtest" {
  display_name = "sp-fuzzing-azure-devtest"
  owners       = data.azuread_group.relops.members
  notes        = "Service principal for the Fuzzing Azure DevTest Subscription. RELOPS-2440."

  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "fuzzing_azure_devtest" {
  client_id                    = azuread_application.fuzzing_azure_devtest.client_id
  app_role_assignment_required = false
  owners                       = data.azuread_group.relops.members
  tags                         = concat(["name:sp-fuzzing-azure-devtest"], local.sp_tags)
}

resource "azuread_application" "clauditor" {
  for_each     = local.clauditor_apps
  display_name = each.value.name
  owners       = data.azuread_group.relops.members
  notes        = each.value.notes
}

resource "azuread_service_principal" "clauditor" {
  for_each  = local.clauditor_apps
  client_id = azuread_application.clauditor[each.key].client_id
  owners    = data.azuread_group.relops.members
  tags      = concat(["name:${each.value.name}"], local.sp_tags)
}

resource "azuread_application_federated_identity_credential" "clauditor" {
  for_each       = local.clauditor_federated_credentials
  application_id = azuread_application.clauditor[each.value.app].id
  display_name   = each.value.display_name
  description    = each.value.description
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = each.value.issuer
  subject        = each.value.subject
}
