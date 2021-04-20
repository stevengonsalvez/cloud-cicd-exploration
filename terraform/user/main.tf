locals {
    organization = "action-foobar"
    userlist=csvdecode(file("${path.module}/../../people.csv"))
}

provider "github" {
  organization = local.organization
}

data "github_user" "example" {
  for_each = { for usr in local.userlist : usr.Username => usr }
  username = each.value.Username
}

resource "github_membership" "this" {
  for_each = { for usr in local.userlist : usr.Username => usr }
  
  username = each.value.Username
  role     = "member"

  # member or admin
}

data "github_membership" "list" {
    for_each = { for usr in local.userlist : usr.Username => usr }
    username = each.value.Username
    organization = local.organization
}

output "org_membership" {
    value = data.github_membership.list 
}

output "user_details" {
  value = data.github_user.example
}