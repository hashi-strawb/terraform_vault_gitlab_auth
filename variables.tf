variable "gitlab_project_path" {
  type        = string
  description = "project path you want to enable JWT auth for"

  # Default is the corresponding GitLab repo
  # https://gitlab.com/hashi-strawb/gitlab_vault_jwt_auth
  default = "hashi-strawb/gitlab_vault_jwt_auth"
}


variable "gitlab_default_lease_ttl" {
  type        = string
  description = "Default lease TTL for Vault tokens"
  default     = "12h"
}

variable "gitlab_max_lease_ttl" {
  type        = string
  description = "Maximum lease TTL for Vault tokens"
  default     = "768h"
}

variable "gitlab_token_type" {
  type        = string
  description = "Token type for Vault tokens"
  default     = "default-service"
}
