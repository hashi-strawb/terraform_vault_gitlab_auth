terraform {
  cloud {
    organization = "hashi_strawb_demo"

    workspaces {
      name = "gitlab_vault_jwt_auth"
    }
  }
}


provider "vault" {
  # Configuration provided by VAULT_ADDR, VAULT_NAMESPACE env vars
  # Credentials provided by VAULT_TOKEN env var
}

resource "vault_namespace" "gitlab_auth" {
  path      = "gitlab_auth"
  namespace = "demos"
}

resource "vault_jwt_auth_backend" "gitlab" {
  namespace = vault_namespace.gitlab_auth.path_fq

  description  = "JWT auth backend for Gitlab-CI pipeline"
  path         = "jwt/gitlab"
  jwks_url     = "https://gitlab.com/-/jwks"
  bound_issuer = "gitlab.com"
  default_role = "app-pipeline"
  tune {
    default_lease_ttl = var.gitlab_default_lease_ttl
    max_lease_ttl     = var.gitlab_max_lease_ttl
    token_type        = var.gitlab_token_type
  }
}

resource "vault_jwt_auth_backend_role" "pipeline" {
  namespace = vault_namespace.gitlab_auth.path_fq

  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name = "app-pipeline"
  token_policies = [
    "default",
    "gitlab-app-pipeline"
  ]

  bound_claims = {
    project_path = var.gitlab_project_path
    ref          = "main"
    ref_type     = "branch"
  }

  # This is used to determine identity within Vault.
  # You can use any field from the JWT for this.
  #
  # In this case, I'm using project_path, so a unique project in GitLab will
  # correspond to a Client within Vault
  user_claim = "project_path"

  # For group, use the namespace
  groups_claim = "namespace_path"

  claim_mappings = {
    "iss"                   = "iss"
    "project_id"            = "project_id"
    "namespace_id"          = "namespace_id"
    "namespace_path"        = "namespace_path"
    "project_id"            = "project_id"
    "project_path"          = "project_path"
    "user_id"               = "user_id"
    "user_login"            = "user_login"
    "user_email"            = "user_email"
    "pipeline_id"           = "pipeline_id"
    "pipeline_source"       = "pipeline_source"
    "job_id"                = "job_id"
    "ref"                   = "ref"
    "ref_type"              = "ref_type"
    "ref_protected"         = "ref_protected"
    "environment"           = "environment"
    "environment_protected" = "environment_protected"
  }
}





#
# Advanced: Entity Groups
#

resource "vault_identity_group" "gitlab-hashi-strawb" {
  namespace = vault_namespace.gitlab_auth.path_fq
  name      = "GitLab Namespace: hashi-strawb"
  type      = "external"
  policies  = ["gitlab-hashi-strawb"]
}

resource "vault_identity_group_alias" "gitlab-hashi-strawb" {
  namespace      = vault_namespace.gitlab_auth.path_fq
  name           = "hashi-strawb"
  mount_accessor = vault_jwt_auth_backend.gitlab.accessor
  canonical_id   = vault_identity_group.gitlab-hashi-strawb.id
}

resource "vault_identity_group" "all-gitlab" {
  namespace = vault_namespace.gitlab_auth.path_fq
  name      = "All GitLab"
  type      = "internal"
  policies  = ["gitlab-all"]
  member_group_ids = [
    vault_identity_group.gitlab-hashi-strawb.id
  ]
}
