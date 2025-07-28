#! /bin/bash

if [[ ! $(command -v gum) ]]; then
    echo "installing gum"
    GUMRELEASE=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest | jq -r '.tag_name')
    GUMDL="https://github.com/charmbracelet/gum/releases/download/${GUMRELEASE}/gum-${GUMRELEASE:1}-1.x86_64.rpm"
    dnf install -y "${GUMDL}"
fi

if [[ "${1}" == "--help" ]]; then
    gum  pager < /workspace/assets/help.md
else
    bash
fi