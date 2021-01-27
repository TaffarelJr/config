# Show current PowerShell version
Write-Host "PowerShell version:"
$PSVersionTable | Out-String | Write-Host

# Set PowerShell preference variables
$ErrorActionPreference = "Stop"

# Install modules
@(
    "powershell-yaml"
    "Poshstache"
) | ForEach-Object {
    Write-Host "Import $_"
    Install-Module $_ -Force
    Import-Module $_
}

# Set custom constants
$vsInstallDir = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE"
$vsMarketplace = "https://marketplace.visualstudio.com"

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

# Create the specified location if it doesn't exist, push to it,
# execute the given Script Block, then pop back to the previous location
function Enter-Location {
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [object]$ScriptBlock
    )

    # Create the location, if necessary
    if (-Not (Test-Path $Path)) {
        New-Item -Path $Path
    }

    # Push to the location
    Push-Location -Path $Path

    # Execute the script block
    & $ScriptBlock

    # Pop back to the previous location
    Pop-Location
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
        Write-Host "Uninstall Windows Store apps like '$AppNamePattern'"
        Get-AppxPackage $AppNamePattern -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppNamePattern | Remove-AppxProvisionedPackage -Online | Format-List | Out-String | Write-Host
        Remove-Item "$Env:LOCALAPPDATA\Packages\$AppNamePattern" -Recurse -Force -ErrorAction 0
    }
}

# Configure Windows Search to search the contents of the specified file extensions
function Set-WindowsSearchFileExtension {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Extension
    )

    process {
        Write-Host "Register extension $Extension"
        Enter-Location -Path "HKCR:\$Extension\" {
            Enter-Location -Path ".\PersistentHandler\" {
                Set-ItemProperty -Path "." -Name "(Default)"                 -Type "String" -Value "{5E941D80-BF96-11CD-B579-08002B30BFEB}"
                Set-ItemProperty -Path "." -Name "OriginalPersistentHandler" -Type "String" -Value "{00000000-0000-0000-0000-000000000000}"
            }
        }
    }
}

# Gather list of installed VS extensions
# (only works after VS is installed)
function Get-InstalledVsix {
    Write-Host "Getting list of Visual Studio extensions that are already installed ..."
    Get-ChildItem -Path "$vsInstallDir\Extensions" -File -Filter "*.vsixmanifest" -Recurse | `
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
        $packagePage = "$vsMarketplace/items?itemName=$PackageName"

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
            Uri         = "$vsMarketplace$anchor"
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
        Start-Process -Filepath "$vsInstallDir\VSIXInstaller.exe" -ArgumentList "/quiet /admin '$VsixFile'" -Wait
        Remove-Item $VsixFile -ErrorAction "Ignore"
        Write-Host "$VsixFile installed successfully"
    }
}

# Downloads & parses the specified theme files
function Import-Theme {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable]$Theme
    )

    process {
        # Load Base16 pallete for selected theme
        Write-Host "Load $($Theme.Base16Uri)"
        (ConvertFrom-Yaml (Invoke-WebRequest -Uri $Theme.Base16Uri -UseBasicParsing).Content).GetEnumerator() | ForEach-Object {
            if ($_.Key -Match "^base0[\dA-F]$") {
                # Composite hex RGB value
                $hex = $_.Value.ToUpper()
                $Theme["$($_.Key)-hex"] = $hex

                # Individual hex RGB values
                $hexRgb = $hex -Split "(.{2})" | Where-Object { $_ }
                $Theme["$($_.Key)-hex-r"] = $hexRgb[0]
                $Theme["$($_.Key)-hex-g"] = $hexRgb[1]
                $Theme["$($_.Key)-hex-b"] = $hexRgb[2]

                # Composite hex BGR value
                $Theme["$($_.Key)-hex-bgr"] = $hexRgb[2] + $hexRgb[1] + $hexRgb[0]

                # Individual int RGB values
                $Theme["$($_.Key)-rgb-r"] = [Convert]::ToByte($hexRgb[0], 16)
                $Theme["$($_.Key)-rgb-g"] = [Convert]::ToByte($hexRgb[1], 16)
                $Theme["$($_.Key)-rgb-b"] = [Convert]::ToByte($hexRgb[2], 16)
            }
            else {
                $Theme[$_.Key] = $_.Value
            }
        }

        return $Theme
    }
}

# Replaces any mustache fields in the given template with the given values (including environment variables)
function Expand-TemplateString {
    param (
        [Parameter(Mandatory)]
        [string]$String,

        [Parameter(Mandatory)]
        [hashtable]$Values
    )

    # Include environment variables
    $Values += [System.Environment]::GetEnvironmentVariables()

    # Convert hashtable to JSON
    $json = $Values | ConvertTo-Json

    # Use Mustache to replace fields with values
    ConvertTo-PoshstacheTemplate -InputString $String -ParametersObject $json
}

function Invoke-CleanupScripts {
    Write-Header "Run clean-up scripts"

    Enable-UAC
    Enable-MicrosoftUpdate
    Install-WindowsUpdate -acceptEula
}
