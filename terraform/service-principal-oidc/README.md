# Service principal with federated oidc spike. This

This is a spike to create a service principal and test federation with
- Github OIDC for github actions
- Kube same


## Stuff
Some defaults to make testing easier

- Contributor role is assigned to the current subscription. So will need to have a subscription set (`az account set -s`) for testing roles


## To run

example:

```shell
export TF_VAR_owner=steven.gonsalvez@theclassroom.dev
export TF_VAR_app_name="tf-oidc-vending-1";
terraform plan
```


and then do standard TF stuff
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->