# running packer templates inside container

This helpfile describes how to use the provided container for building 
virtual machines or proxmox templates.

Think about this container like an execution environment: it serves all
tools for deploying and testing the provided packer-templates. All 
templates are located under /workspace. Each directory represents a single
template