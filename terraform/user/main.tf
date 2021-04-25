locals {
  organization = "action-foobar"
  userlist     = concat(csvdecode(file("${path.module}/../../bots.csv")), csvdecode(file("${path.module}/../../people.csv")))

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
}

output "input_user" {
  value = local.userlist
}
output "user_details" {
  value = data.github_user.example
}
