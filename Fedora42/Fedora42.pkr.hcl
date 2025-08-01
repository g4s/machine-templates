/* Fedora 42 minimal template
   
   Builder:
     - proxmox
     - qemu
   
   This template will create base-installations of Fedora 42, with a minimal
   set of provisioning.

   This template is heavy inspired by https://github.com/ChristianLempa/boilerplates/blob/main/packer/proxmox/ubuntu-server-focal/ubuntu-server-focal.pkr.hcl
   You can also find additional information at:
     - https://pve.proxmox.com/wiki/Cloud-Init_Support
     - https://joshrnoll.com/deploying-fedora-servers-with-cloudinit-on-proxmox/
     - https://www.youtube.com/watch?v=1nf3WOEFq1Y
     - https://www.youtube.com/watch?v=dvyeoDBUtsU
     - https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso

   Original the intention was to provide (automation)templates in a 
   comfortable way. - Which is the reason, that all variables will get their
   values from the env. 
*/
packer {
  required_plugins {
    proxmox = {
      version            = "~> 1"
      source             = "github.com/hashicorp/proxmox"
    },
    testinfra = [
        version          = "~> 1.5.8"
        source           = "github.com/mschuchard/testinfra"
    ]
  }
}

variable "proxmox_api_uri" {
    type    = string
    default = env("PROXMOX_API_URI")
}

variable "proxmox_api_token_id" {
    type    = string
    default = env("PROXMOX_API_TOKEN_ID")
}

variable "proxmox_api_token_secret" {
    type      = string
    sensitive = true
    default   = env("PROXMOX_API_TOKEN_SECRET")
}

variable "proxmox_node" {
    type = string
    default = env("PROCMOX_NODE")
}

variable "proxmox_storage_pool" {
    type = string
    default = env("PROXMOX_STORAGE_POOL")
}

locals {
    iso_url      = "https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-dvd-x86_64-42-1.1.iso"
    iso_checksum ="https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-42-1.1-x86_64-CHECKSUM"
}

source "proxmox" "fedora42-base" {
    proxmox_url             = "${var.proxmox_api_uri}"
    username                = "${var.proxmox_api_token_id}"
    token                   = "${var.proxmox_api_token_secret}"
    node                    = "${var.proxmox_node}"

    vm_name                 = "fedora42-minimal"
    template_description    = "a minimal Fedora 42 installation" 
    boot_iso {
        type                = "scsi"
        iso_file            = "${local.iso_url}"
        iso_checksum        = "${local.iso_checksum}"
        unmount             = true
    }
    qemu_agent              = true
    scsi_controller         = "virtio-scsi-pci"
    disks {
        disk_size           = "40G"
        format              = "qcow2"
        storage_pool        = "${proxmox_storage_pool}"
        type                = "virtio"
    }
    cores                   = "${vm_cores}"
    memory                  = "${vm_ram}"
    vga {
        type                = "qxl"
        memory              = 128
    }
    network_adapters {
        model               = "virtio"
        bridge              = "vmbr0"
        firewall            = "false"
    }

    cloud_init              = true
    cloud_init_storage_pool = "${proxmox_storage_pool}"

    // @ToDo insert boot-cmds

    // We can use a very simple password for root, cause we will later change
    // this during post-create provisioning.
    // If you not have provisioning pipelines, which change the credentials
    // you should change this in this template.
    ssh_username            = "root"
    ssh_password            = "Initial123!"
    ssh_timeout             = "20m"
}

source "qemu" "fedora42-base" {
    accelerator  = "kvm"
    iso_url      = "https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-dvd-x86_64-42-1.1.iso"
    iso_checksum = "https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-42-1.1-x86_64-CHECKSUM"
}

build {
    name    = "fedora42-minimal"
    sources = [
        "source.proxmox.fedora42-base",
        "source.qemu.fedora42-base"
        ]

    provisioner "shell" {
        inline = [
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo useradd -G wheel provisioner",
            "sudo dnf update -y",
            "sudo dnf install -y qemu-guest-agent",
            "sudo dnf install -y ansible",
            "sudo dnf autoremove -y",
            "sudo dnf clean all",
            "sudo sync"
        ]
    }

    // prepare cloudcofig on proxmox
    provisioner "shell" {
        only = [ "source.proxmox.fedora42-base" ]
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finishesd]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo dnf install -y cloud-init",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/"
        ]
    }
 
    provisioner "file" {
        only        = ["source.proxmox.fedora42-base"]
        source      = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        only   = [ "source.proxmox.fedora42-base" ]
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    // ensure ansible autp provisioning is present on machine
    provisioner "shell" {
        inline = [ 
            "touch /auto-provision"
        ]
    }

    provisioner "file" {
        source           = "assets/autoprovision.service"
        destination      = "/etc/systemd/system/autprovision.service"
    }

    provisioner "file" {
        source           = "assets/autoprovision.timer"
        destination      = "/etc/systemd/system/autoprovision.timer"
    }

    provisioner "file" {
        source           = "assets/autoprovision.sh"
        destination      = "/usr/bin/autoprovision"
    }

    provisioner "shell" {
        inline = [
            "chmod 0700 /usr/bin/autoprovision"
            ]
    }

    provisioner "shell" {
        inline = [
            "systemctl daemon-reload",
            "systemctl enable --now autoprovision.timer"
        ]
    }

    // adding image tests
    provisioner "testinfra" {
        only = [ "source.proxmox.fedora42-base" ]
        sudo = false
        test_files = [ 
            "${path.root}/tests/test-general.py",
            "${path.root}/tests/test-proxmox.py" 
            ]
    }

    provisioner "testinfra" {
        only = [ "source.qemu.fedora42-base" ]
        sudo = false
        test_files = [ 
            "${path.root}/tests/test-general.py",
            "${path.root}/tests/test-qemu.py" 
            ] 
    }
}