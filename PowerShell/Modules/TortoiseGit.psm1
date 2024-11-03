function Set-TortoiseGitDiffTool {
    <#
        .SYNOPSIS
            Sets the diff tool command line used by TortoiseGit.

        .PARAMETER Command
            The command line to be used as the diff tool.
            Optional. Defaults to $null.
            If this value is specified in combination with UseBuiltIn,
            the command will still be stored--but will be disabled.

        .PARAMETER UseBuiltIn
            If specified, the built-in diff tool is used.
            If specified in combination with Command,
            the command will still be stored--but will be disabled.
    #>

    param(
        [Parameter(Position = 0)]
        [string] $Command = $null,

        [Parameter(Position = 1)]
        [switch] $UseBuiltIn
    )

    # Mark the command as disabled, if necessary
    if (($UseBuiltIn) -and ($null -ne $Command) -and ($Command.Length -gt 0)) {
        $Command = "#$Command"
    }

    # Save the diff tool command
    Assert-RegistryValue `
        -Hive CurrentUser `
        -Key 'Software\TortoiseGit' `
        -ValueName 'Diff' `
        -ValueData $Command
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Set-TortoiseGitDiffTool
