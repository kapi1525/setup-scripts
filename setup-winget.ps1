# Note: This script was made with Windows LTSC in mind, it may work on normal windows but didnt test.
# https://learn.microsoft.com/en-us/windows/iot/iot-enterprise/deployment/install-winget-windows-iot

#Requires -RunAsAdministrator

Write-Host "Setting up winget"

$ProgressPreference = "SilentlyContinue"
$null = New-Item -Name "temp" -Type Directory -Force


function Download($url, $filename) {
    if($url -eq "") {
        throw "Missing url"
    }

    Write-Host "Downloading $url..."

    if(Test-Path .\temp\$filename) {
        Write-Host "Files found, skipping..."
        return
    }

    Invoke-WebRequest $url -OutFile ".\temp\$filename"
}

function Extract($filename) {
    if($filename -eq "") {
        throw "Missing filename"
    }

    $dest_path = ($filename | Select-String -Pattern "(.*)\..*").Matches.Groups[1]

    Write-Host "Extracting $filename..."
    Expand-Archive -Path ".\temp\$filename" -DestinationPath ".\temp\$dest_path" -Force
}

function InstallAppx($filename) {
    if($filename -eq "") {
        throw "Missing filename"
    }

    Write-Host "Installing $filename..."
    Add-AppxPackage -Path ".\temp\$filename"
}



$to_download = @(
    @{
        Uri = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
        OutFile = "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    },
    @{
        Uri = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml"
        OutFile = "Microsoft.UI.Xaml.zip"
    }
)


$winget_latest = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

ForEach ($asset in (Invoke-WebRequest $winget_latest | ConvertFrom-Json).assets) {
    if($asset.name -match ".*\.msixbundle") {
        $to_download += @{
            Uri = $asset.browser_download_url
            OutFile = "winget.msixbundle"
        }
    }
    if($asset.name -match ".*License1\.xml") {
        $to_download += @{
            Uri = $asset.browser_download_url
            OutFile = "winget-license.xml"
        }
    }
}

ForEach ($i in $to_download) {
    Download $i.Uri $i.OutFile
}

Extract "Microsoft.UI.Xaml.zip"

InstallAppx "Microsoft.VCLibs.x64.14.00.Desktop.appx"
InstallAppx "Microsoft.UI.Xaml\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx"

Write-Host "Installing winget.msixbundle..."
Add-AppxProvisionedPackage -Online -PackagePath "temp\winget.msixbundle" -LicensePath "temp\winget-license.xml"

Write-Host "Install complete."
