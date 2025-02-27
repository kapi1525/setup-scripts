Some scripts for setting up windows.

before running some scripts you may need:
`set-executionpolicy unrestricted`
in powershell

- #### setup-winget.ps1
  Installs winget and all its dependencies, made for Windows 11 LTSC.
- #### setup-virtiofs.bat
  Installs dependencies and enables virtiofs driver. (note: virtio drivers need to be installed first!)
- #### setup-explorer.ps1
  Enables file extensions, hiddent files and dak mode.
- #### setup-git-gnupg.ps1
  Installs git gnupg and github desktop, configures commit signing.
- #### setup-ssh.ps1
  Installs OpenSSH server and configures it to use key based authentication.
- #### ssh-keycopy.ps1
  Copies a ssh key to correct location.


Usefull:

- [Setting up network bridge on linux for VMs](https://github.com/Hit360D/bridged-networking-KVM)