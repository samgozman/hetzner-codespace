terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 1.3.4"
}

#! Create .auto.tfvars file with the following content:
# hcloud_token = "<your_hetzner_api_key>"
variable "hcloud_token" {}
variable "os_type" {
  default = "ubuntu-22.04"
}
variable "datacenter" {
  default = "nbg1-dc3"
}
variable "location" {
  default = "nbg1"
}
variable "server_type" {
  default = "cpx21"
}

provider "hcloud" {
  token = var.hcloud_token
}

# Your SSH key to connect from your local machine to the VM
resource "hcloud_ssh_key" "default" {
  name       = "hetzner_key"
  public_key = file("id_rsa.pub")
}

# SSH key for GitHub Actions to connect to the VM
resource "hcloud_ssh_key" "github" {
  name       = "key_for_github"
  public_key = file("id_rsa_github.pub")
}

## Firewall

# Public SSH access for connection (this can be improved by using a firewall rule for the specific IP)
resource "hcloud_firewall" "ssh_firewall_public" {
  name = "ssh_firewall_public"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
    ]
    description = "SSH"
  }
}

## VMs

resource "hcloud_server" "codespace" {
  name        = "linux-space"
  image       = var.os_type
  server_type = var.server_type
  datacenter  = var.datacenter
  ssh_keys = [
    hcloud_ssh_key.default.id,
    hcloud_ssh_key.github.id
  ]
  backups = false
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.public.id
  }
  firewall_ids = [
    hcloud_firewall.ssh_firewall_public.id,
  ]
  user_data = file("cloud-config.yml")
}

## Network

# Create public static IP address
resource "hcloud_primary_ip" "public" {
  name              = "primary_public_ip"
  datacenter        = var.datacenter
  type              = "ipv4"
  assignee_type     = "server"
  auto_delete       = false
  delete_protection = false
}

## Output

output "servers_ip" {
  value = hcloud_server.codespace.ipv4_address
}