# Copies provided ssh key to correct user or admin.

#Requires -RunAsAdministrator


$pubkey_path = Read-Host "Enter path to your public key"

$user = Read-Host "Enter user name"

$user_path = "C:\Users\$user\.ssh"
if(!Test-Path "$user_path") {
    $null = New-Item -Name $user_path -Type Directory -Force
}

$key = Get-Content -Path "$pubkey_path"


$was_key_resent = $null
if(Test-Path "$user_path\authorized_keys") {
    $was_key_resent = Select-String -Path "$user_path\authorized_keys" -Pattern "$key" -Quiet
}

if ($was_key_resent -eq $null) {
    Add-Content -Force -Path "$user_path\authorized_keys" -Value "$key"
    Write-Host "Key was copied."
}
else {
    Write-Host "Key was already copied before."
}

