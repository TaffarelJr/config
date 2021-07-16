# Show current PowerShell version
Write-Host "PowerShell version:"
$PSVersionTable | Out-String | Write-Host

# Set PowerShell preference variables
$ErrorActionPreference = "Stop"

# Make sure the PSGallery is trusted
$galleryName = "PSGallery"
$trustLevel = "Trusted"
if ($(Get-PSRepository -Name "PSGallery" | Select-Object -ExpandProperty "InstallationPolicy") -ne $trustLevel) {
    Set-PSRepository -Name $galleryName -InstallationPolicy $trustLevel
}

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
$vsUserDir = "$Env:LOCALAPPDATA\Microsoft\VisualStudio"
$vsInstallDir = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE"
$vsMarketplace = "https://marketplace.visualstudio.com"
$edition = (Get-WindowsEdition -Online).Edition

# Configure Chocolatey cache path. This is a workaround for a current bug:
# https://github.com/chocolatey/boxstarter/issues/241
$chocoCache = "$Env:LOCALAPPDATA\Temp\ChocoCache"
New-Item -Path $chocoCache -ItemType directory -Force | Out-Null
$chocoCache = "--cacheLocation=`"$chocoCache`""

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

    try {
        # Push to the location
        Push-Location -Path $Path

        # Execute the script block
        & $ScriptBlock
    }
    finally {
        # Pop back to the previous location
        Pop-Location
    }
}

# Disable specified Windows Services
function Disable-WindowsService {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Service
    )

    process {
        Write-Host "Disable Windows Service '$Service'"
        Set-Service -Name $Service -StartupType "Disabled"
        Stop-Service $Service
    }
}

# Disable specified application startup
function Disable-Startup {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$App
    )

    process {
        Write-Host "Disable application startup for '$App'"
        Enter-Location -Path "HKLM:\SOFTWARE\" {
            Enter-Location -Path ".\Microsoft\Windows\CurrentVersion\Run\" {
                Remove-ItemProperty -Path "." -Name $App -ErrorAction "Ignore"
            }
            Enter-Location -Path ".\Wow6432Node\Microsoft\Windows\CurrentVersion\Run\" {
                Remove-ItemProperty -Path "." -Name $App -ErrorAction "Ignore"
            }
        }
        Enter-Location -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" {
            Remove-ItemProperty -Path "." -Name $App -ErrorAction "Ignore"
        }
        Enter-Location -Path "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\" {
            Remove-Item $App -ErrorAction "Ignore"
        }
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
        Remove-Item "$Env:LOCALAPPDATA\Packages\$AppNamePattern" -Recurse -Force -ErrorAction "Ignore"
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
    Write-Host "Get list of Visual Studio extensions that are already installed ..."
    Get-ChildItem -Path $vsUserDir, "$vsInstallDir\CommonExtensions", "$vsInstallDir\Extensions" -File -Filter "*.vsixmanifest" -Recurse | `
        Select-String -List -Pattern '<Identity .*?Id="(.+?)"' | `
        ForEach-Object { $_.Matches.Groups[1].Value } | `
        Sort-Object
}

# Scrapes the VS Marketplace web page to get the VSIX ID and download URI of the specified packages
function Get-VsixInfo {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [object]$Session
    )

    process {
        # Format the URL to the VSIX web page in the Marketplace
        $packagePage = "$vsMarketplace/items?itemName=$PackageName"

        # Download the VSIX web page
        Write-Host "Scrape VSIX details from $packagePage ..."
        $response = Invoke-WebRequest -Uri $packagePage -UseBasicParsing -WebSession $Session
        if ($response.StatusCode -NE 200) { throw [System.IO.InvalidOperationException] "Could not find VSIX page at $packagePage" }

        # Get the unique ID of the VSIX package
        $vsixId = $response.Content | Select-String -List -Pattern '"VsixId":"(.+?)"' | ForEach-Object { $_.Matches.Groups[1].Value }
        if (-Not $vsixId) { throw [System.IO.InvalidOperationException] "Could not find ID for $PackageName" }

        # Get the relative path to the VSIX download
        $link = $response.Links | Where-Object { $_.class -eq "install-button-container" }
        if (-Not $link) { throw [System.IO.InvalidOperationException] "Could not find download link for $PackageName" }

        # Return new custom data structure
        [PSCustomObject]@{
            Id          = $vsixId
            PackageName = $PackageName
            Uri         = "$vsMarketplace$($link.href)"
        }
    }
}

# Downloads the specified VSIX packages.
function Get-Vsix {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Vsix,

        [Parameter(Mandatory)]
        [object]$Session
    )

    process {
        # Create download file name
        $vsixFileName = "$Env:TEMP\$($Vsix.PackageName).vsix"

        # Download VSIX
        Write-Host "Download $($Vsix.Uri) ..."
        Invoke-WebRequest -Uri $Vsix.Uri -OutFile $vsixFileName -UseBasicParsing -WebSession $Session

        # Verify the file was downloaded
        if (Test-Path $vsixFileName) {
            return $vsixFileName
        }
        else {
            throw [System.IO.InvalidOperationException] "Could not download VSIX from $($Vsix.Uri)"
        }
    }
}

# Installs the specified VSIX extensions
function Install-Vsix {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$VsixFile
    )

    process {
        # Install the extension
        Write-Host "Install $VsixFile ..."
        Start-Process -Filepath "$vsInstallDir\VSIXInstaller.exe" -ArgumentList "/quiet /admin /force `"$VsixFile`"" -Wait
        Remove-Item $VsixFile -ErrorAction "Ignore"
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
