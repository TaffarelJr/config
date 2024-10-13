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

Export-ModuleMember -Function Assert-WinGetSource
