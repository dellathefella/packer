// Plugins
// https://github.com/rgl/packer-plugin-windows-update
// https://github.com/hashicorp/packer-plugin-hyperv

// https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
// ISO: https://answers.microsoft.com/en-us/windows/forum/all/downloading-the-oscdimg-utility-for-windows-11/bd0b478d-6df0-4dd9-8cae-3adb469405a0

packer {
  required_version = ">= 1.9.4"
  required_plugins {
    vmware = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/hyperv"
    }
    windows-update = {
      version = ">= 0.14.3"
      source  = "github.com/rgl/windows-update"
    }
  }
}

locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "output_directory" {
  type        = string
  description = "Output for storage of artifacts."
  default     = null
}

variable "temp_path" {
  type        = string
  description = "Output for temporary files during the build."
  default     = null
}

variable "vm_name" {
  type        = string
  description = "Image name"
}

variable "vm_cpus" {
  type        = string
  description = "amount of vCPUs"
}

variable "vm_disk_size" {
  type        = string
  description = "Harddisk size"
}

variable "vm_memory" {
  type        = string
  description = "VM Memory"
}

variable "win_iso" {
  type        = string
  description = "Windows 10 ISO location"
}

variable "win_checksum" {
  type        = string
  description = "Windows ISO checksum"
}

variable "winrm_username" {
  type        = string
  description = "winrm username"
}

variable "winrm_password" {
  type        = string
  description = "winrm password"
  sensitive   = true
}

variable "switch_name" {
  type        = string
  description = "switch name"
}

variable "dynamic_memory" {
  type        = bool
  description = "Dynamic Memory"
}

variable "secure_boot" {
  type        = bool
  description = "Secure boot"
}

variable "tpm" {
  type        = bool
  description = "TPM"
}

variable "generation" {
  type        = number
  description = "Generation"
}

variable "headless" {
  type        = bool
  description = "Headless"
}

variable "skip_export" {
  type        = bool
  description = "Headless"
}

variable "enable_virtualization_extensions" {
  type        = bool
  description = "enable_virtualization_extensions"
}

variable "guest_additions_mode" {
  type        = string
  description = "switch name"
}

source "hyperv-iso" "windows11" {
  boot_command     = ["a<enter><wait>a<enter><wait>a<enter><wait>a<enter>"]
  boot_wait        = "1s"
  output_directory = var.output_directory
  temp_path        = var.temp_path
  // VM specifications
  vm_name                          = var.vm_name
  cpus                             = var.vm_cpus
  memory                           = var.vm_memory
  enable_dynamic_memory            = var.dynamic_memory
  disk_size                        = var.vm_disk_size
  skip_export                      = var.skip_export
  switch_name                      = var.switch_name
  iso_checksum                     = var.win_checksum
  iso_url                          = var.win_iso
  headless                         = var.headless
  generation                       = var.generation
  enable_secure_boot               = var.secure_boot
  enable_tpm                       = var.tpm
  enable_virtualization_extensions = var.enable_virtualization_extensions
  guest_additions_mode             = var.guest_additions_mode
  // WinRM config
  communicator     = "winrm"
  winrm_port       = "5985"
  winrm_username   = var.winrm_username
  winrm_password   = var.winrm_password
  winrm_timeout    = "12h"
  shutdown_command = "shutdown /s /t 10 /f"
  cd_content = {
    "enable-rdp.cmd"      = file("./scripts/enable-rdp.cmd"),
    "enable-winrm.ps1"    = file("./scripts/enable-winrm.ps1"),
    "disable-autolog.ps1" = file("./scripts/disable-autolog.ps1"),
    "autounattend.xml"    = templatefile("./templates/autounattend.pkrtmpl.xml", { vm_name = var.vm_name }),
  }
  cd_label = "scripts"
}

build {
  sources = ["source.hyperv-iso.windows11"]

  provisioner "windows-update" {
    pause_before    = "30s"
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*VMware*'",
      "exclude:$_.Title -like '*Preview*'",
      "exclude:$_.InstallationBehavior.CanRequestUserInput",
      "include:$true"
    ]
    restart_timeout = "120m"
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "20m"
  }

  provisioner "powershell" {
    elevated_user     = var.winrm_username
    elevated_password = var.winrm_password
    scripts           = ["./scripts/disable-autolog.ps1"]
  }

  provisioner "file" {
    destination = "C:/test-config.yaml"
    content     = templatefile("./templates/test-config.pkrtmpl.yaml", { vm_name = var.vm_name, build_timestamp = formatdate("YYYY.MM.DD", timestamp())  })
  }

}