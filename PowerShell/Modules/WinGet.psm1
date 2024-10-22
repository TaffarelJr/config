$packageDir = "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages"

#-------------------------------------------------------------------------------

function Get-WinGetPackageDir {
    <#
        .SYNOPSIS
            Retrieves the directory path for the specified WinGet package.

        .PARAMETER Name
            The name of the WinGet package.

        .OUTPUTS
            The directory path for the specified WinGet package,
            or $null if the package is not installed.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Name
    )

    $package = Get-ChildItem -Path $packageDir -Filter "$Name*" -Directory
    if ($null -ne $package) {
        return $package.FullName
    }
}

#-------------------------------------------------------------------------------

function Assert-WinGetSource {
    <#
        .SYNOPSIS
            Ensures the specified WinGet source is registered.

        .PARAMETER Name
            The name of the WinGet source.

        .PARAMETER Uri
            The URI of the WinGet source.

        .PARAMETER Type
            The type of the WinGet source.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Name,

        [Parameter(Position = 1, Mandatory)]
        [string] $Uri,

        [Parameter(Position = 2, Mandatory)]
        [string] $Type
    )

    $source = Get-WinGetSource | Where-Object { $_.Name -eq $Name }
    if ($null -eq $source) {
        # Create the source if it doesn't exist
        Write-Host "Registering $Name ..."
        Add-WinGetSource -Name $Name -Argument $Uri -Type $Type
    }
    elseif (($source.Argument -ne $Uri) -or ($source.Type -ne $Type)) {
        # Update the source if necessary
        Write-Host "Updating $Name ..."
        Remove-WinGetSource -Name $Name
        Add-WinGetSource -Name $Name -Argument $Uri -Type $Type
    }
}

#-------------------------------------------------------------------------------

function Assert-WinGetPackage {
    <#
        .SYNOPSIS
            Ensures the specified WinGet package is installed.

        .PARAMETER Name
            The name of the package to install.

        .PARAMETER Confirm
            A script block that can be used to
            confirm the package was installed correctly.
            Optional. Defaults to returning the installed package version.
    #>

    param (
        [Parameter(Position = 0, Mandatory)]
        [string] $Name,

        [Parameter(Position = 1)]
        [ScriptBlock] $Confirm = {
            Get-WinGetPackage "$Name" `
            | Select-Object -ExpandProperty 'InstalledVersion'
        }
    )

    Write-Host 'Installing WinGet package ''' -NoNewline
    Write-Host $Name -ForegroundColor 'DarkCyan' -NoNewline
    Write-Host ''' ...'
    winget install --exact "$Name" --source=winget `
        --accept-package-agreements `
        --accept-source-agreements

    Confirm-Installation -ScriptBlock $Confirm
}

#-------------------------------------------------------------------------------

function Assert-WinGetUpdates {
    <#
        .SYNOPSIS
            Ensures any WinGet package (or Microsoft Store app) updates are installed.
    #>

    Start-Component 'WinGet Updates'

    winget upgrade --all --accept-package-agreements --accept-source-agreements
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Get-WinGetPackageDir
Export-ModuleMember -Function Assert-WinGetSource
Export-ModuleMember -Function Assert-WinGetPackage
Export-ModuleMember -Function Assert-WinGetUpdates
