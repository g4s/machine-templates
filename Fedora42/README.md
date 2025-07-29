# Fedora 42
This template will deploy a Fedora 42 machine on

  * proxmox (as a vm template)
  * KVM

## building images (with TUI)
Besides the template, there is a script called prepare.sh, which can guide
you during the creation process of your image and will initialize packer
and also will parametrize the the packer tool. (In the background it will
call a pypyr pipeline, which also calls packer).

During the execution of the script you can select which image should be
build. If "proxmox" is choosen, you will be prompted to provide some
information about your proxmox installation

## building images (direct calling pypyr pipeline)
If you decides to call the pypyr pipeline directly you must provide
sufficient information for the build process with environment variables.

For proxmox this means:
```bash 
$:> export API_URI="<PVE API>"
$:> export API_TOKEN_ID="<PVE_API_USER>"
$:> export API_TOKEN_SECRET="<PVE_API_SECRET>"
$:> export PVE_NODE="<NODE_OF _CLUSTER>"
$:> export PVE_STORAGE="<STORAGEPOOL>"
$:> pypyr build proxmox
```
If the provided deploy-container is used, it's also possible to populate
the information during container starting as environment variables. This gives
you the ablility to provide this information in automations.

For KVM this means:
```bash
$:> pypyr build qemu
```
It's quite simple, cause the qemu builder in this template does not accept
parameters at this point.

You can also show this file as a help document with
```bash
$:> pypyr build help
```