# terraform_vault_gitlab_auth
Quick terraform job to configure Gitlab JWT Auth

GitHub version of this repo: https://github.com/hashi-strawb/terraform_vault_gitlab_auth

(I use GitHub as a source-of-truth for my repos, for consistency)

GitLab version of this repo: https://gitlab.com/hashi-strawb/gitlab_vault_jwt_auth


## Pre requirements
to use this terraform code you will need access to GitLab (the free SaaS GitLab.com version is fine) and Vault (the OSS version is fine but I used HCP Vault).


### terraform provider
this code needs that the Vault and JWT provider access be set as enviroment variables:
```bash
export VAULT_TOKEN=<VAULT_TOKEN>
export VAULT_ADDR=https://<VAULT_ADDRESS>:8200
export VAULT_NAMESPACE=admin # if using HCP Vault

```
### terraform variables
this project has one manatory variable *gitlab_project_path* which is the name of the project you want to enable the JWT Auth Method for.
this can be set by creating a terraform.tfvars file:

```text
gitlab_project_path = "hashi-strawb/gitlab_vault_jwt_aut"
```

(See example.auto.tfvars as an example)

## running the code

```bash
terraform init
terraform apply
```


## Entities & JWT Auth
JWT Auth Method creates entities based on the *user_claim* configured at the Vault JWT Auth Method role; These can be a field from the [JWT token itself](https://docs.gitlab.com/ee/ci/examples/authenticating-with-hashicorp-vault/index.html#how-it-works)

In this example, we use project_path as the user claim. This means that each GitLab project becomes an entity (and therefore client) within Vault.

It is also possible to use the bound_claim to specify the match paramaters that allow authentication.


## Example GitLab pipelines

When running in a project which matches the bound_claim:

```
Executing "step_script" stage of the job script
00:01
Using docker image sha256:06de113a5ba9ab785f3ca786ce1234f805a3d84462adff99c9360f62b48f9497 for vault:1.9.0 with digest vault@sha256:b16dc6ba7319005d281b34013da19012eb1713b16400d45b62e15c8f06e70d44 ...
$ export VAULT_TOKEN="$(vault write -field=token auth/jwt/gitlab/login role=app-pipeline jwt=$CI_JOB_JWT)"
$ vault read --field=display_name auth/token/lookup-self
admin-auth-jwt-gitlab-hashi-strawb/gitlab_vault_jwt_auth
Cleaning up project directory and file based variables
00:01
Job succeeded
```

When running in a project which does not match the bound_claim:

```
Executing "step_script" stage of the job script
00:02
Using docker image sha256:06de113a5ba9ab785f3ca786ce1234f805a3d84462adff99c9360f62b48f9497 for vault:1.9.0 with digest vault@sha256:b16dc6ba7319005d281b34013da19012eb1713b16400d45b62e15c8f06e70d44 ...
$ export VAULT_TOKEN="$(vault write -field=token auth/jwt/gitlab/login role=app-pipeline jwt=$CI_JOB_JWT)"
Error writing data to auth/jwt/gitlab/login: Error making API request.
URL: PUT https://vault-cluster.vault.d6c96d2b-616b-4cb8-b78c-9e17a78c2167.aws.hashicorp.cloud:8200/v1/auth/jwt/gitlab/login
Code: 400. Errors:
* error validating claims: claim "project_path" does not match any associated bound claim values
$ vault read --field=display_name auth/token/lookup-self
Error reading auth/token/lookup-self: Error making API request.
URL: GET https://vault-cluster.vault.d6c96d2b-616b-4cb8-b78c-9e17a78c2167.aws.hashicorp.cloud:8200/v1/auth/token/lookup-self
Code: 400. Errors:
* missing client token
Cleaning up project directory and file based variables
00:01
ERROR: Job failed: exit code 2
```






## Notice
this currently is for reference , PRs welcomed.
