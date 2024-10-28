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

Export-ModuleMember -Function Assert-ChocolateyProfile
