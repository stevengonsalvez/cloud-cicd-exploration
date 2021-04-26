locals {
  organization = "DigitalInnovation"
  userlist     = concat(csvdecode(file("${path.module}/../../bots.csv")), csvdecode(file("${path.module}/../../users.csv")))
  # userlist     = csvdecode(file("${path.module}/../../bots.csv"))

}

provider "github" {
  organization = local.organization
}

/* Commenting out this part - as exhaustive github API causing to exhaust api rates
data "github_user" "example" {
  for_each = { for usr in local.userlist : usr.Username => usr }
  username = each.value.Username
} 
*/

resource "github_membership" "this" {
  for_each = { for usr in local.userlist : usr.Username => usr }

  username = each.value.Username
  role     = each.value.Role
}


/* Uncomment to see the list of users as input
output "input_user" {
  value = local.userlist
}
*/

/* Commenting out this part - as exhaustive github API causing to exhaust api rates
output "user_details" {
  value = data.github_user.example
} 
*/
