# Setup openssh server and client
# Copied some code from: https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse

#Requires -RunAsAdministrator

Write-Host "Setting up OpenSSH"

$to_install = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

ForEach ($i in $to_install) {
    $name = $i.name
    if($i.State -eq "Installed") {
        Write-Host "$name is already installed, skipping..."
        continue
    }
    Write-Host "Installing $name..."
    Add-WindowsCapability -Online -Name $name
}


Start-Service sshd
Set-Service -Name "sshd" -StartupType "Automatic"


# Confirm the Firewall rule is configured. It should be created automatically by setup.
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Host "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# todo handle key auth