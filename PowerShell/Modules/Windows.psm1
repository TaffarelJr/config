using namespace System.Security.Principal

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

Export-ModuleMember -Function Assert-Admin
