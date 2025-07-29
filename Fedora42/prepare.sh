#! /bin/bash

IMAGES=[ "proxmox", "kvm" ]

SELECTION $(echo "${IMAGES[@]}" | gum chose --limit 1 --header "Which image would you like to generate?")

case $SELECTION in
    proxmox)
        export API_URI=$(gum input --placeholder "Enter PVE API url")
        export API_TOKEN_ID=$(gum input --placeholder "Enter PVE API token id")
        export API_TOKEN_SECRET=$(gum input --placeholder "Enter PVE API token secret" --password)
        export PVE_NODE=$(gum input --placeholder "Enter PVE node")
        export PVE_STORAGE=$(gum input --placeholder "Enter PVE storage pool")

        pypyr build proxmox
        
        break
        ;;
    kvm)
        pypyr build qemu
        break
        ;;
esac