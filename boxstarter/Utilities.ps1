New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null

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

function Configure-WindowsSearchFileExtension {
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
