using namespace System.Security.Principal
using namespace System.IO

#-------------------------------------------------------------------------------

function Assert-Admin {
    <#
        .SYNOPSIS
            Ensures the current user has admin permissions.
            Otherwise, throws an exception.
    #>

    $identity = [WindowsIdentity]::GetCurrent()
    $principal = New-Object WindowsPrincipal($identity)

    if ($principal.IsInRole([WindowsBuiltInRole]::Administrator)) {
        Write-Host 'Admin permissions detected'
    }
    else {
        throw 'This script requires admin permissions'
    }
}

#-------------------------------------------------------------------------------

function Assert-ComputerName {
    <#
        .SYNOPSIS
            Prompts the user to change the name of the computer.
    #>

    Write-Host
    Write-Host "Computer name is: $Env:COMPUTERNAME"
    Write-Host 'What would you like to change it to?'
    $name = Read-Host -Prompt '<press ENTER to skip>'

    if (($null -ne $name) -and ($name.Length -gt 0)) {
        Rename-Computer -NewName $name
    }
}

#-------------------------------------------------------------------------------

function Assert-Shortcut {
    <#
        .SYNOPSIS
            Ensures a shortcut exists in the specified location
            targeting the specified file.

        .PARAMETER Location
            The path to the location where the shortcut should exist.

        .PARAMETER Target
            The path to the file that should be targeted by the shortcut.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Location,

        [Parameter(Position = 1, Mandatory)]
        [string] $Target
    )

    # Check if a shortcut exists at the specified location
    if (-not (Test-Path -Path $Location)) {
        # If not, create it
        Write-Host "Creating shortcut to '$([Path]::GetFileName($Target))'"
        $shell = New-Object -COMObject 'WScript.Shell'
        $shortcut = $shell.CreateShortcut($Location)
        $shortcut.TargetPath = $Target
        $shortcut.Save()
    }
}

#-------------------------------------------------------------------------------

function Disable-WindowsService {
    <#
        .SYNOPSIS
            Ensures the specified Windows service is stopped
            and set to manual start only.

        .PARAMETER Name
            The name of the Windows service.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [string] $Name
    )

    process {
        try {
            # Get the specified service
            $service = Get-Service -Name $Name
        }
        catch {
            # If the service is not found, do nothing
        }

        if ($null -ne $service) {
            # If the service is running, stop it
            if ($service.Status -eq 'Running') {
                Write-Host "Stopping $($service.DisplayName)"
                Stop-Service -Name $Name
            }

            # If the service is set to start automatically, make it manual
            if ($service.StartType -eq 'Automatic') {
                Write-Host "Setting $($service.DisplayName) to manual start"
                Set-Service -Name $Name -StartupType Manual
            }
        }
    }
}

#-------------------------------------------------------------------------------

function Remove-FromWindowsStartup {
    <#
        .SYNOPSIS
            Ensures the specified application does not start up with Windows.

        .PARAMETER Name
            The name of the application.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [string] $Name
    )

    # There are 4 places where apps can be registered to start automatically;
    # we need to make sure the app is removed from all of them.
    process {
        Remove-RegistryValue `
            -Hive LocalMachine `
            -Key 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run' `
            -ValueName $Name

        Remove-RegistryValue `
            -Hive LocalMachine `
            -Key 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' `
            -ValueName $Name

        Remove-RegistryValue `
            -Hive CurrentUser `
            -Key 'Software\Microsoft\Windows\CurrentVersion\Run' `
            -ValueName $Name

        Remove-File -Path `
            "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$Name"
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-Admin
Export-ModuleMember -Function Assert-ComputerName
Export-ModuleMember -Function Assert-Shortcut
Export-ModuleMember -Function Disable-WindowsService
Export-ModuleMember -Function Remove-FromWindowsStartup
