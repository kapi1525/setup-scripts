# Show file extensions hiddent files darkmode

Write-Host "Setting up Explorer"


# https://stackoverflow.com/a/8110982
$explorer_key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $explorer_key Hidden 1
Set-ItemProperty $explorer_key HideFileExt 0

$darkmode_key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty $darkmode_key AppsUseLightTheme 0
Set-ItemProperty $darkmode_key SystemUsesLightTheme 0

Stop-Process -processname explorer
