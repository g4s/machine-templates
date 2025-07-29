import pytest
import testinfa

## check if ansible can provision the host
def test_user_provisioner(host):
    assert host.user("provisioner").exists
    assert host.user('provisioner').expiration_date == None
    assert "wheel" in host.user("provisioner").groups


def test_provision_ready(host):
    assert host.package("ansible").is_installed
    assert host.package("git").is_installed
    assert host.file("/auto-provision").exists

    assert host.file("/etc/systemd/system/autoprovision.service").exists
    assert host.file("/etc/systemd/system/autoprovision.timer").exists
    assert host.service("autoprovision.timer").is_enabled
    
    assert host.file("/usr/bin/autoprovision").exists
    assert host.file("/usr/bin/autoprovision").is_executable