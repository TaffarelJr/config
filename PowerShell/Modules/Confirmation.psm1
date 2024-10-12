function Confirm-Installation {
    <#
        .SYNOPSIS
            Tests an installation to make sure it succeeded.

        .PARAMETER Label
            An extra descriptor of the installation test, if needed.
            Optional.

        .PARAMETER ScriptBlock
            The script block to run to test the installation.
    #>

    param(
        [Parameter(Position = 0)]
        [string] $Label = $null,

        [Parameter(Position = 1, Mandatory)]
        [ScriptBlock] $ScriptBlock
    )

    if ($Label) {
        Write-Host "$Label confirmation: " -ForegroundColor 'DarkCyan' -NoNewline
    }
    else {
        Write-Host "Confirmation: " -ForegroundColor 'DarkCyan' -NoNewline
    }

    & $ScriptBlock | Write-Host -ForegroundColor 'Green'
    if (-not $?) {
        throw "Failed to install $Label"
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Confirm-Installation
