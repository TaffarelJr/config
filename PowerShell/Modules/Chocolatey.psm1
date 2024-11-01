function Assert-ChocolateyProfile {
    <#
        .SYNOPSIS
            Ensures the Chocolatey profile, if it exists,
            is loaded into the current session.
    #>

    if ($Env:ChocolateyInstall) {
        Write-Host 'Loading Chocolatey profile'
        Import-Module -Name "$Env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    }
}

#-------------------------------------------------------------------------------

function Assert-ChocolateySource {
    <#
        .SYNOPSIS
            Ensures the specified Chocolatey source is registered.

        .PARAMETER Name
            The name of the Chocolatey source.

        .PARAMETER Uri
            The URI of the Chocolatey source.

        .PARAMETER Priority
            The priority of the Chocolatey source.
            Lower number means higher priority.
            Optional. Defaults to 0.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Name,

        [Parameter(Position = 1, Mandatory)]
        [string] $Uri,

        [Parameter(Position = 2)]
        [int] $Priority = 0
    )

    # The PowerShell module seems to be having trouble creating sources properly;
    # so for now we have to resort to the command line instead.

    $source = Get-ChocolateySource | Where-Object { $_.Name -eq $Name }
    if ($null -eq $source) {
        # Create the source if it doesn't exist
        Write-Host "Registering source '$Name' ..."
        choco source add --name=$Name --source=$Uri --priority=$Priority --limitoutput
    }
    elseif (($source.Source -ne $Uri) `
            -or ($source.Priority -ne $Priority) `
            -or ($source.Disabled)) {
        # Update the source if necessary
        Write-Host "Updating source '$Name' ..."
        choco source remove --name=$Name --limitoutput
        choco source add --name=$Name --source=$Uri --priority=$Priority --limitoutput
    }
}

#-------------------------------------------------------------------------------

function Assert-ChocolateyPackage {
    <#
        .SYNOPSIS
            Ensures the specified Chocolatey package is installed.

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
            Get-ChocolateyPackage "$Name" `
            | Select-Object -ExpandProperty 'Version'
        }
    )

    Write-Host 'Installing Chocolatey package ''' -NoNewline
    Write-Host $Name -ForegroundColor 'DarkCyan' -NoNewline
    Write-Host ''' ...'
    choco upgrade "$Name" --yes --limitoutput

    Confirm-Installation -ScriptBlock $Confirm
}

#-------------------------------------------------------------------------------

function Assert-ChocolateyUpdates {
    <#
        .SYNOPSIS
            Ensures any Chocolatey package updates are installed.
    #>

    Start-Component 'Chocolatey Updates'

    choco upgrade all --yes --limitoutput
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-ChocolateyProfile
Export-ModuleMember -Function Assert-ChocolateySource
Export-ModuleMember -Function Assert-ChocolateyPackage
Export-ModuleMember -Function Assert-ChocolateyUpdates
