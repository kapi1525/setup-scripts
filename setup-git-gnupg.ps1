# Setup openssh server and client
# Copied some code from: https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse

#Requires -RunAsAdministrator

Write-Host "Installing..."
winget install Git.MinGit GnuPG.GnuPG GitHub.cli --silent --accept-package-agreements --accept-source-agreements

# https://stackoverflow.com/a/31845512
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Git configuration..."
$git_email = ""
$git_name = ""
$git_sign = ""
$git_gpg = (where.exe gpg)

for(;;) {
    $git_email = Read-Host "Enter email"
    if($git_email -ne "") {
        break;
    }
}

for(;;) {
    $git_name = Read-Host "Enter name"
    if($git_name -ne "") {
        break;
    }
}

for(;;) {
    $git_sign = Read-Host "Sign all commits by default [Y/n]"
    if($git_sign -eq "" -or $git_sign -eq "y") {
        $git_sign = "true"
        break;
    }
    if($git_sign -eq "n") {
        $git_sign = "false"
        break;
    }
}


Write-Host "Gpg configuration..."
$gpg_key_path = Read-Host "Path to your private gpg signing key"

Write-Host "Saving settings..."

if($gpg_key_path -ne "") {
    gpg --import "$gpg_key_path"
    $signing_key = ((gpg --list-secret-keys --keyid-format LONG) | Select-String -Pattern "sec.*\/(\S*) 20.*").Matches.Groups[1]
    Write-Host "Key \"$signing_key\" will be used to sign commits."
    git config --global user.signingkey "$signing_key"
}

git config --global user.email "$git_email"
git config --global user.name "$git_name"
git config --global commit.gpgsign "$git_sign"
git config --global gpg.program "$git_gpg"

Write-Host "Login to github cli."
gh auth login

Write-Host "Configuration complete."