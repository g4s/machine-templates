#! /bin/bash

REPO_URL="https://github.com/g4s/autoprovision.git"
SKIP_TAGS="vpn,goodnight"

ansible-galaxy role install git+https://github.com/g4s/de.seafi.minimalinstall.git

ansible-pull -U "${REPO_URL}" -c local -i localhost -d /tmp/provisioning --skip-tags="${SKIP_TAGS}"

if [[ $? == 0 ]]; then
    rm /auto-provisioning
fi