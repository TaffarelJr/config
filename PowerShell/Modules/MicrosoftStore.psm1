function Assert-MicrosoftStoreApp {
    <#
        .SYNOPSIS
            Ensures the specified Microsoft Store app is installed.

        .PARAMETER Name
            The name of the app to install.

        .PARAMETER Confirm
            A script block that can be used to
            confirm the app was installed correctly.
            Optional. Defaults to returning the installed app version.
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

    # Microsoft Store apps are installed using WinGet now
    Write-Host 'Installing Microsoft Store app ''' -NoNewline
    Write-Host $Name -ForegroundColor 'DarkCyan' -NoNewline
    Write-Host ''' ...'
    winget install --exact "$Name" --source=msstore `
        --accept-package-agreements `
        --accept-source-agreements

    Confirm-Installation -ScriptBlock $Confirm
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-MicrosoftStoreApp
