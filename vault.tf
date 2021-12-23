provider "vault" {
  # Configuration provided by VAULT_ADDR, VAULT_NAMESPACE env vars
  # Credentials provided by VAULT_TOKEN env var
}

resource "vault_jwt_auth_backend" "gitlab" {
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
  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name      = "app-pipeline"
  token_policies = ["default"]

  bound_claims = {
    project_path = var.gitlab_project_path
    ref          = "main"
    ref_type     = "branch"
  }

  user_claim = "project_path"

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

