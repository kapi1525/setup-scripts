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


Write-Host "Starting OpenSSH server..."
Start-Service "sshd"
Set-Service -Name "sshd" -StartupType "Automatic"


# Confirm the Firewall rule is configured. It should be created automatically by setup.
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Host "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}


$ssh_config = "C:\ProgramData\ssh\sshd_config"

Write-Host "Waiting for server to create sshd_config..."
for(;;) {
    if(Test-Path $ssh_config) {
        Write-Host "sshd_config has been created."
        break
    }
    Start-Sleep -Seconds 0.5
}


$was_script_ran_before = Select-String -Path $ssh_config -Pattern "setup-ssh.ps1" -Quiet

if($was_script_ran_before) {
    Write-Host "This script was ran before and sshd_config is already configured."
} else {
    Write-Host "Configuring sshd_config..."
    Add-Content -Path $ssh_config -Value "# Lines added by setup-ssh.ps1 script:"
    Add-Content -Path $ssh_config -Value "# Enable key based authentication"
    Add-Content -Path $ssh_config -Value "PubkeyAuthentication yes"
    Add-Content -Path $ssh_config -Value "# Disable password based authentication"
    Add-Content -Path $ssh_config -Value "PasswordAuthentication no"

    $line1_to_edit = "Match Group administrators"
    $line2_to_edit = "       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys"
    (Get-Content $ssh_config).Replace($line1_to_edit, "# $line1_to_edit") | Set-Content $ssh_config
    (Get-Content $ssh_config).Replace($line2_to_edit, "# $line2_to_edit") | Set-Content $ssh_config
}


Write-Host "Restarting OpenSSH server..."
Restart-Service "sshd"
