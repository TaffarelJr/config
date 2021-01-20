# Set PowerShell preference variables
$ErrorActionPreference = "Stop"

# Set custom variables
$vsInstallDir = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE"
$vsMarketplace = "https://vsMarketplace.visualstudio.com"

# Register HKEY_CLASSES_ROOT as an accessible drive
New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null

# Have Boxstarter disable UAC
Disable-UAC

# Draw a pretty header to identify different sections of output
function Write-Header {
    Param (
        [string]$text
    )

    $color = "Yellow"
    $line = "-" * $text.Length

    Write-Host
    Write-Host "+-$($line)-+" -ForegroundColor $color
    Write-Host "| $($text) |" -ForegroundColor $color
    Write-Host "+-$($line)-+" -ForegroundColor $color
    Write-Host
}

# Disable specified Windows Services
function Disable-WindowsService {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$service
    )

    process {
        Write-Host "Disable Windows Service '$service' ... " -NoNewline
        Set-service -Name $service -StartupType "Disabled"
        Write-Host "Done"
    }
}

# Uninstall specified Windows Store applications
function Remove-WindowsStoreApp {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$app
    )

    process {
        Write-Host "Uninstalling $app ... " -NoNewline
        Get-AppxPackage $app -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online
        Remove-Item "$Env:LOCALAPPDATA\Packages\$app" -Recurse -Force -ErrorAction 0
        Write-Host "Done"
    }
}

# Configure Windows Search to search the contents of the specified file extensions
function Set-WindowsSearchFileExtension {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$extension
    )

    process {
        Write-Host "Register extension $extension ... " -NoNewline
        $regPath = "HKCR:\$extension\PersistentHandler\"

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

# Download & install specified Visual Studio extensions
# Modified from https://gist.github.com/ScottHutchinson/b22339c3d3688da5c9b477281e258400
function Install-VsixPackage() {
    param (
        [string]$packageName = $(throw "Please specify a Visual Studio Extension" )
    )

    # Scrape the VS Marketplace web page, to get the download path and VSIX ID
    $packagePage = "$vsMarketplace/items?itemName=$packageName"
    Write-Host "Scrape VSIX details from $packagePage"
    $response = Invoke-WebRequest -Uri $packagePage -UseBasicParsing
    $anchor = $response.Links | Where-Object { $_.class -eq "install-button-container" } | Select-Object -ExpandProperty "href"
    if (-Not $anchor) {
        Write-Error "Could not find download anchor tag on the Visual Studio Extensions page"
        exit 1
    }
    $vsixId = $response.Content | Select-String -List -Pattern '"VsixId":"(.+?)"' | ForEach-Object { $_.Matches.Groups[1].Value }
    if (-Not $vsixId) {
        Write-Error "Could not find VSIX ID on the Visual Studio Extensions page"
        exit 1
    }

    # Check to see if the extension is already installed
    if ($installedVsExtensions -Contains $vsixId) {
        Write-Host "Already installed. Skipping"
    }
    else {
        # If not, then download it
        $packageUri = "$vsMarketplace$anchor"
        $vsixFileName = "$Env:TEMP\$packageName.vsix"
        Write-Host "Attempting to download $packageUri ..."
        Invoke-WebRequest -Uri $packageUri -OutFile $vsixFileName -UseBasicParsing -Headers @{
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
        if (-Not (Test-Path $vsixFileName)) {
            Write-Error "Downloaded VSIX file could not be located"
            exit 1
        }

        # Install the extension
        Write-Host "Installing $vsixFileName ..."
        Start-Process -Filepath "$vsInstallDir\VSIXInstaller.exe" -ArgumentList "/quiet /admin '$vsixFileName'" -Wait
        Remove-Item $vsixFileName
        Write-Host "Installation of $packageName complete!"
    }
}

function Invoke-CleanupScripts() {
    Write-Header "Run clean-up scripts"

    Enable-UAC
    Enable-MicrosoftUpdate
    Install-WindowsUpdate -acceptEula
}
