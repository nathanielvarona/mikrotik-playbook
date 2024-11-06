# mikrotik-playbook

A modular collection of Ansible playbooks for automating MikroTik RouterOS configurations. Designed for IT administrators, this project simplifies network setup, ensures consistent configurations, and provides scalable, reusable tasks for common RouterOS networking scenarios.

## MikroTik Router Emulation

### Build a VM using Packer

```bash
cd ./packer

packer build -var-file=variables/routeros_6.49.17.pkr.hcl routeros.pkr.hcl
```
