<!-- SPDX-License-Identifier: BSD-3-Clause --> 
# packer machine templates

This repository provides a collection of packer templates for creating
fresh virtual machines. Each template is placed in a subfolder and can
be used from this.

If you wish to have an immutable build environment you can use the included
container-file to build a custom env. This repository will not served a
pre-built container-image. Inside this container alle tools and a help file
is included.

Original this repo was designed to deliver templates for a (home)lab
automation like [kestra.io](https://kestra.io)

NOTE: The proxmox provisioner will only create VM-templates on your
proxmox setup. For deploying fully working vms it is neccessary to
create them from the template: manually or with tools likes terraform.

## using this repo
```bash
$:> git clone https://github.com/g4s/machine-templates.git
$:> cd machine-templates
$:> podman build -t packer .
$:> podman container run-label run packer
packer #:> cd /workspace/<template>
packer #:> packer init <template>.pkr.hcl2
packer #:> packer build
```
If the container is not used for building process, you change directly to
the correct sub-dir in this repo and build from there. (This is necessary
e.g. when building KVM-Machines). Attention: in this case you should ensure
that testinfra is present on your host.