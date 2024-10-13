$configFile = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

#-------------------------------------------------------------------------------

function Get-WindowsTerminalConfig {
    <#
        .SYNOPSIS
            Gets the Windows Terminal configuration.

        .OUTPUTS
            The Windows Terminal configuration object.
    #>

    Get-Content $configFile -Raw | ConvertFrom-Json
}

#-------------------------------------------------------------------------------

function Set-WindowsTerminalConfig {
    <#
        .SYNOPSIS
            Sets the Windows Terminal configuration.

        .PARAMETER Config
            The Windows Terminal configuration.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [object] $Config
    )

    $Config | ConvertTo-Json -Depth 10 | Set-Content $configFile
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Get-WindowsTerminalConfig
Export-ModuleMember -Function Set-WindowsTerminalConfig
