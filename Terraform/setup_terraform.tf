#Boundary server information
provider "boundary" {
  addr                            = "http://127.0.0.1:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}

#List of server IP
variable "backend_server_ips" {
  type    = set(string)
  default = [
    "192.168.1.17"
  ]
}

# Define global scope
resource "boundary_scope" "global" {
  global_scope = true
  description  = "Global scope"
  scope_id     = "global"
}
# Define organisation
resource "boundary_scope" "aitech" {
  name                     = "aitech"
  description              = "aitech scope!"
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# Define authentication methode
resource "boundary_auth_method" "password" {
  name     = "aitech Password"
  scope_id = boundary_scope.aitech.id
  type     = "password"
}

#Define project
resource "boundary_scope" "aitech_infra" {
  name                   = "aitech_infra"
  description            = "aitech project"
  scope_id               = boundary_scope.aitech.id
  auto_create_admin_role = true
}

# Define Host Catalogs
resource "boundary_host_catalog" "backend_servers" {
  name        = "backend_servers"
  description = "Backend servers host catalog"
  type        = "static"
  scope_id    = boundary_scope.aitech_infra.id
}

# Define Hosts
resource "boundary_host" "backend_servers" {
  for_each        = var.backend_server_ips
  type            = "static"
  name            = "backend_server_service_${each.value}"
  description     = "Backend server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

# Define Host Sets
resource "boundary_host_set" "backend_servers_ssh" {
  type            = "static"
  name            = "backend_servers_ssh"
  description     = "Host set for backend servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.backend_servers : host.id]
}

# create target for accessing backend servers on port :22
resource "boundary_target" "backend_servers_ssh" {
  type         = "tcp"
  name         = "ssh_server"
  description  = "Backend SSH target"
  scope_id     = boundary_scope.aitech_infra.id
  default_port = "22"
  host_source_ids = [boundary_host_set.backend_servers_ssh.id]
}
# Manager identity in boundary

# Create account
resource "boundary_account" "aitechfirstaccount" {
  name           = "aitech01"
  description    = "aitech01 account"
  type           = "password"
  login_name     = "aitech01"
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

# Create user
resource "boundary_user" "aitech" {
  name        = "aitech"
  description = "aitech identity"
  account_ids = [
     boundary_account.aitechfirstaccount.id
  ]
  scope_id    = boundary_scope.aitech.id
}

# Create groupe and add aitech user to support group
resource "boundary_group" "support" {
  name        = "Support group"
  description = "Support group"
  member_ids  = [boundary_user.aitech.id]
  scope_id    = boundary_scope.aitech.id
}

# Create role and add group to role
resource "boundary_role" "support_role" {
  name        = "Support"
  description = "Support role"
  principal_ids = [boundary_group.support.id]
  grant_strings = ["id=*;type=*;actions=read"]
  scope_id    = boundary_scope.aitech.id
}