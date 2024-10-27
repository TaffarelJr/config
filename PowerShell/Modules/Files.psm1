function Assert-File {
    <#
        .SYNOPSIS
            Ensures a file exists.

        .PARAMETER Path
            The path to the file.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Host "Creating file '$Path'"
        New-Item -Path $Path -ItemType File
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-File
