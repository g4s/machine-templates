import testinfa

def test_os_release(host):
    pass

## check if ansible can provision the host
def test_user_provisioner(host):
    assert host.user("provisioner").exists
    assert host.user('provisioner').expiration_date == None
    assert "wheel" in host.user("provisioner").groups


def test_provision_ready(host):
    assert host.pacckage("ansible").is_installed
    assert host.file("/auto-provision").exists

    assert host.file("/etc/systemd/system/autoprovision.service").exists
    assert host.service("autoprovision.service").is_enabled
    
    assert host.file("/usr/bin/autoprovision").exists
    assert host.file("/usr/bin/autoprovision").is_executable