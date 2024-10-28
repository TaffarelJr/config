using namespace System.Net

#-------------------------------------------------------------------------------

function Initialize-Environment {
    <#
        .SYNOPSIS
            Configures the execution environment for subsequent scripts.
    #>

    $global:ErrorActionPreference = 'Stop'
    $global:ProgressPreference = 'SilentlyContinue'

    if (-not $global:EnvironmentIsInitialized ) {
        # First, admin mode is required before anything else
        Assert-Admin
        Write-Host 'Bypassing execution policy'
        Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'Process' -Force
        Assert-PowerShellLanguageMode

        # Install any PSModules that may be needed during installation
        @(
            'chocolatey',
            'Microsoft.WinGet.Client'
        ) | Assert-PowerShellModule

        # Initialize Chocolatey
        Assert-ChocolateyProfile
        Write-Host 'Enabling TLS 1.2'
        [ServicePointManager]::SecurityProtocol = `
            [ServicePointManager]::SecurityProtocol -bor `
            [ServicePointManager]::Tls12

        # Prepare the registry, and allow the user to make a backup
        Assert-RegistryDrives
        Write-Host
        Backup-Registry

        # No need to run this again in the current session
        $global:EnvironmentIsInitialized = $true
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Initialize-Environment
