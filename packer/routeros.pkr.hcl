packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

# Variables
variable "disk_size" {
  type    = string
  default = "61440"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "intnet" {
  type    = string
  default = "intnet"
}

variable "shutdown_command" {
  type    = string
  default = "/system shutdown"
}

variable "ssh_password" {
  type    = string
  default = "mikrotik"
}

variable "ssh_timeout" {
  type    = string
  default = "5m"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "ros_version" {
  type    = string
  default = "latest"
}

variable "iso_checksum" {
  type    = string
  default = ""
}

locals {
  ver_major = split(".", var.ros_version)[0]
  ver_minor = split(".", var.ros_version)[1]
  install_seq = local.ver_major >= 7 ? "aiy" : "ainy"
}

# Source
source "virtualbox-iso" "mikrotik" {
  boot_command            = [
    local.install_seq,
    "<wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><enter>", # Waiting for Disk Formating and Packages Installation 
    "<wait10><wait10>", # Waiting for First Reboot
    "<wait2>", # Waiting for Login Ready
    "admin<enter><wait2>",
    "<enter><wait2>",
    "<enter><wait2>",
    "Y<wait2>",
    "q<wait2>",
    "<enter><wait2>",
    "mikrotik<enter><wait2>",
    "mikrotik<enter><wait2>",
    "/ip dhcp-client add disabled=no interface=ether1<enter>",
    "<wait2>"
  ]

  boot_wait               = "15s"
  communicator            = "ssh"
  disk_size               = var.disk_size
  guest_additions_mode    = "disable"
  guest_os_type           = "Linux_64"
  hard_drive_interface    = "sata"
  headless                = var.headless
  iso_checksum            = var.iso_checksum
  iso_url                 = "https://download.mikrotik.com/routeros/${var.ros_version}/mikrotik-${var.ros_version}.iso"
  output_directory        = "./output/build/{{ build_name }}/mikrotik-${var.ros_version}"
  shutdown_command        = var.shutdown_command
  ssh_password            = var.ssh_password
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username

  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--memory", "256"],
    ["modifyvm", "{{ .Name }}", "--cpus", "2"],
    ["modifyvm", "{{ .Name }}", "--nic1", "nat"],
    ["modifyvm", "{{ .Name }}", "--nic2", var.intnet],
    ["modifyvm", "{{ .Name }}", "--nic3", var.intnet],
    ["modifyvm", "{{ .Name }}", "--nic4", var.intnet],
    ["modifyvm", "{{ .Name }}", "--nic5", var.intnet]
  ]

  virtualbox_version_file = ""
  vm_name                 = "mikrotik-${var.ros_version}"
}

# Build
build {
  sources = ["source.virtualbox-iso.mikrotik"]

  # Provisioner
  provisioner "shell" {
    execute_command = "/import verbose=yes {{ .Path }}"
    remote_path     = "default_configuration.rsc"
    script          = "scripts/default_configuration.rsc"
    skip_clean      = true
  }

  # Post-processor
  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "./output/box/mikrotik-routeros-${var.ros_version}.box"
    vagrantfile_template = "./templates/Vagrantfile.template"
  }
}