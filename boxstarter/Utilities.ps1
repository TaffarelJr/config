# Set PowerShell preference variables
$ErrorActionPreference = "Stop"

# Set custom constants
Set-Variable VsInstallDir  -Option Constant -Value "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE"
Set-Variable VsMarketplace -Option Constant -Value "https://marketplace.visualstudio.com"

# Register HKEY_CLASSES_ROOT as an accessible drive
New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null

# Have Boxstarter disable UAC
Disable-UAC

# Draw a pretty header to identify different sections of output
function Write-Header {
    Param (
        [Parameter(Mandatory)]
        [string]$Text
    )

    $color = "Yellow"
    $line = "-" * $Text.Length

    Write-Host
    Write-Host "+-$($line)-+" -ForegroundColor $color
    Write-Host "| $($Text) |" -ForegroundColor $color
    Write-Host "+-$($line)-+" -ForegroundColor $color
    Write-Host
}

# Disable specified Windows Services
function Disable-WindowsService {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Service
    )

    process {
        Write-Host "Disable Windows Service '$Service' ... " -NoNewline
        Set-Service -Name $Service -StartupType "Disabled"
        Write-Host "Done"
    }
}

# Uninstall specified Windows Store applications
function Remove-WindowsStoreApp {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$AppNamePattern
    )

    process {
        Write-Host "Uninstalling $AppNamePattern ... " -NoNewline
        Get-AppxPackage $AppNamePattern -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppNamePattern | Remove-AppxProvisionedPackage -Online
        Remove-Item "$Env:LOCALAPPDATA\Packages\$AppNamePattern" -Recurse -Force -ErrorAction 0
        Write-Host "Done"
    }
}

# Configure Windows Search to search the contents of the specified file extensions
function Set-WindowsSearchFileExtension {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Extension
    )

    process {
        Write-Host "Register extension $Extension ... " -NoNewline
        $regPath = "HKCR:\$Extension\PersistentHandler\"

        # Create the registry key if it doesn't already exist
        if (-Not (Test-Path $regPath)) {
            New-Item $regPath -Force | Out-Null
        }

        # Set the registry values in the key
        Push-Location -Path $regPath; & {
            Set-ItemProperty -Path "." -Name "(Default)"                 -Type "String" -Value "{5E941D80-BF96-11CD-B579-08002B30BFEB}"
            Set-ItemProperty -Path "." -Name "OriginalPersistentHandler" -Type "String" -Value "{00000000-0000-0000-0000-000000000000}"
        }; Pop-Location

        Write-Host "Done"
    }
}

# Gather list of installed VS extensions
# (only works after VS is installed)
function Get-InstalledVsix {
    Write-Host "Getting list of Visual Studio extensions that are already installed ..."
    Get-ChildItem -Path "$VsInstallDir\Extensions" -File -Filter "*.vsixmanifest" -Recurse | `
        Select-String -List -Pattern '<Identity .*Id="(.+?)"' | `
        ForEach-Object { $_.Matches.Groups[1].Value } | `
        Sort-Object
}

# Scrapes the VS Marketplace web page to get the VSIX ID and download URI of the specified packages
function Get-VsixPackageInfo {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$PackageName
    )

    process {
        # Format the URL to the VSIX web page in the Marketplace
        $packagePage = "$VsMarketplace/items?itemName=$PackageName"

        # Download the VSIX web page
        Write-Host "Scraping VSIX details from $packagePage ..."
        $response = Invoke-WebRequest -Uri $packagePage -UseBasicParsing

        # Get the unique ID of the VSIX package
        $vsixId = $response.Content | Select-String -List -Pattern '"VsixId":"(.+?)"' | ForEach-Object { $_.Matches.Groups[1].Value }
        if (-Not $vsixId) { throw [System.IO.InvalidOperationException] "Could not find VSIX ID on $packagePage" }

        # Get the relative path to the VSIX download
        $anchor = $response.Links | Where-Object { $_.class -eq "install-button-container" } | Select-Object -ExpandProperty "href"
        if (-Not $anchor) { throw [System.IO.InvalidOperationException] "Could not find download anchor tag on $packagePage" }

        # Return new custom data structure
        [PSCustomObject]@{
            Id          = $vsixId
            PackageName = $PackageName
            Uri         = "$VsMarketplace$anchor"
        }
    }
}

# Downloads the specified VSIX packages.
function Get-VsixPackage {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Vsix
    )

    process {
        # Create download file name
        $vsixFileName = "$Env:TEMP\$($Vsix.PackageName).vsix"

        # Download VSIX
        Write-Host "Attempting to download $($Vsix.Uri) ..."
        Invoke-WebRequest -Uri $Vsix.Uri -OutFile $vsixFileName -UseBasicParsing -Headers @{
            "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
            "accept-encoding"           = "gzip, deflate, br"
            "accept-language"           = "en-US,en;q=0.9"
            "dnt"                       = "1"
            "sec-fetch-dest"            = "document"
            "sec-fetch-mode"            = "navigate"
            "sec-fetch-site"            = "same-origin"
            "sec-fetch-user"            = "?1"
            "upgrade-insecure-requests" = "1"
            "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36"
        }

        if (Test-Path $vsixFileName) {
            return $vsixFileName
        }
        else {
            throw [System.IO.InvalidOperationException] "Could not download VSIX from $($Vsix.Uri)"
        }
    }
}

# Installs the specified VSIX extensions
function Install-VsixPackage {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$VsixFile
    )

    process {
        # Install the extension
        Write-Host "Installing $VsixFile ..."
        Start-Process -Filepath "$VsInstallDir\VSIXInstaller.exe" -ArgumentList "/quiet /admin '$VsixFile'" -Wait
        Remove-Item $VsixFile -ErrorAction "Ignore"
        Write-Host "$VsixFile installed successfully"
    }
}

function Invoke-CleanupScripts {
    Write-Header "Run clean-up scripts"

    Enable-UAC
    Enable-MicrosoftUpdate
    Install-WindowsUpdate -acceptEula
}
