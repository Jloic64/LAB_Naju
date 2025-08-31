terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.40.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pm_api_url
  api_token = "${var.pm_user}!${var.pm_token_id}=${var.pm_token_secret}"
  insecure  = var.pm_tls_insecure
}

resource "proxmox_virtual_environment_vm" "debian_vm" {
  name        = "debian12-projet-1"
  description = "VM déployée avec Terraform"
  tags        = ["terraform", "debian", "projet-1"]
  node_name   = "BRUCE"

  clone {
    vm_id = 3001
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    file_format  = "qcow2"
    datastore_id = "vm-ceph"
    interface    = "scsi0"
    size         = 10
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "vm-ceph"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    dns {
      domain  = "tutotech.org"
      servers = ["1.1.1.1", "8.8.8.8"]
    }
  }

  startup {
    order = 1
  }
}
