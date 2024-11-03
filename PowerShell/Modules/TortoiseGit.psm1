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

function Set-TortoiseGitDiffViewer {
    <#
        .SYNOPSIS
            Sets the diff viewer (patch file) command line used by TortoiseGit.

        .PARAMETER Command
            The command line to be used as the diff viewer.
            Optional. Defaults to $null.
            If this value is specified in combination with UseBuiltIn,
            the command will still be stored--but will be disabled.

        .PARAMETER UseBuiltIn
            If specified, the built-in diff viewer is used.
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

    # Save the diff viewer command
    Assert-RegistryValue `
        -Hive CurrentUser `
        -Key 'Software\TortoiseGit' `
        -ValueName 'DiffViewer' `
        -ValueData $Command
}

#-------------------------------------------------------------------------------

function Set-TortoiseGitMergeTool {
    <#
        .SYNOPSIS
            Sets the merge tool command line used by TortoiseGit.

        .PARAMETER Command
            The command line to be used as the merge tool.
            Optional. Defaults to $null.
            If this value is specified in combination with UseBuiltIn,
            the command will still be stored--but will be disabled.

        .PARAMETER UseBuiltIn
            If specified, the built-in merge tool is used.
            If specified in combination with Command,
            the command will still be stored--but will be disabled.

        .PARAMETER Block
            If specified, TortoiseGit will block while executing
            the external merge tool.

        .PARAMETER TrustExitCode
            If specified, TortoiseGit will trust the exit code
            of the external merge tool for auto-resolving.
            Can only be used in combination with Block.
    #>

    param(
        [Parameter(Position = 0)]
        [string] $Command = $null,

        [Parameter(Position = 1)]
        [switch] $UseBuiltIn,

        [Parameter(Position = 2)]
        [switch] $Block,

        [Parameter(Position = 3)]
        [switch] $TrustExitCode
    )

    # Mark the command as disabled, if necessary
    if (($UseBuiltIn) -and ($null -ne $Command) -and ($Command.Length -gt 0)) {
        $Command = "#$Command"
    }

    # Save the merge tool command
    Assert-RegistryValue `
        -Hive CurrentUser `
        -Key 'Software\TortoiseGit' `
        -ValueName 'Merge' `
        -ValueData $Command

    # Save the block/trust configuration
    Assert-RegistryValue `
        -Hive CurrentUser `
        -Key 'Software\TortoiseGit' `
        -ValueName 'MergeBlockTrustBehavior' `
        -ValueData (if ($Block) { if ($TrustExitCode) { 2 } else { 1 } } else { 0 })
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Set-TortoiseGitDiffTool
Export-ModuleMember -Function Set-TortoiseGitDiffViewer
Export-ModuleMember -Function Set-TortoiseGitMergeTool
