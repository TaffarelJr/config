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

function Remove-File {
    <#
        .SYNOPSIS
            Ensures a file does not exist.

        .PARAMETER Path
            The path to the file.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Path
    )

    if (Test-Path -Path $Path) {
        Write-Host "Deleting file '$Path'"
        Remove-Item -Path $Path
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-File
Export-ModuleMember -Function Remove-File
