using namespace System.Management.Automation

#-------------------------------------------------------------------------------

function Assert-PowerShellLanguageMode {
    <#
        .SYNOPSIS
            Ensures the current PowerShell session
            is running in `FullLanguage` mode.
            Otherwise, throws an exception.
            https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/design/script-enforcement#powershell
            https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes
            https://learn.microsoft.com/en-us/powershell/scripting/security/app-control/how-wdac-works
    #>

    # Get the current LanguageMode
    # (try to set it, just in case it's possible)
    $expected = [PSLanguageMode]::FullLanguage
    $ExecutionContext.SessionState.LanguageMode = $expected
    $actual = $ExecutionContext.SessionState.LanguageMode
    Write-Host "PowerShell LanguageMode: $actual"

    # If the LanguageMode is incorrect,
    # try to fix the relevent settings before throwing
    if ($actual -ne $expected) {
        $varName = '__PSLockDownPolicy'
        Assert-EnvVar -Name $varName -Value ([int]$expected)
        Assert-RegistryValue `
            -Hive LocalMachine `
            -Key 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment' `
            -ValueName $varName `
            -ValueData ([int]$expected)

        throw 'PowerShell must be running in FullLanguage mode.'
    }
}

#-------------------------------------------------------------------------------

function Assert-PowerShellModule {
    <#
        .SYNOPSIS
            Ensures the specified PowerShell module is installed and available.

        .PARAMETER Name
            The name of the PowerShell module to be installed.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [string] $Name
    )

    process {
        # Check if the module is already installed
        $module = Get-Module -Name $Name -ListAvailable
        if ($null -eq $module) {
            # If not, install it
            Write-Host "Installing PowerShell module '$Name'"
            Install-Module -Name $Name -Scope 'AllUsers' -Force
        }
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-PowerShellLanguageMode
Export-ModuleMember -Function Assert-PowerShellModule
