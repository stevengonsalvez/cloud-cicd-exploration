# Azure vending maching to issue service principals with OIDC

This is an altered implementation of the [service principal oidc](../service-principal-oidc), with few more inputs.

An example of how to GitOps the issuance of service principals across an organisation.

> to run
> export of variables

```
export TF_VAR_owners=[\"steven.gonsalvez@theclassroom.dev\",\"foo.bar@theclassroom.dev\"];
export TF_VAR_app_name="tf-oidc-vending-1";
export TF_VAR_subscription_ids=[\"d5563bd6-something\",\"0277c11d-something\"];
export TF_VAR_environments=[\"Nonprod\",\"prod\",\"stage\"]
terraform plan
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->