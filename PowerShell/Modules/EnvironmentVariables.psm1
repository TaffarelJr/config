function Assert-EnvVar {
    <#
        .SYNOPSIS
            Ensures an environment variable exists and
            is set to the specified value,
            creating it if necessary.

        .PARAMETER Name
            The name of the environment variable.

        .PARAMETER Value
            The value of the environment variable.

        .PARAMETER Target
            The target level of the environment variable.
            Optional. Defaults to 'Machine'.

        .PARAMETER IncludeProcess
            If specified, the environment variable will also
            be added to the current process.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Name,

        [Parameter(Position = 1, Mandatory)]
        [string] $Value,

        [Parameter(Position = 2)]
        [EnvironmentVariableTarget] $Target = [EnvironmentVariableTarget]::Machine,

        [Parameter(Position = 3)]
        [switch] $IncludeProcess
    )

    # Get the current value of the environment variable
    $currentValue = [Environment]::GetEnvironmentVariable($Name, $Target)

    # Set the environment variable, if necessary
    if ($null -eq $currentValue) {
        Write-Host "Creating $Target environment variable '$Name' set to '$Value'"
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }
    elseif ($currentValue -cne $Value) {
        Write-Host "Setting $Target environment variable '$Name' to '$Value'"
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }

    # Also add the environment variable to the current process, if necessary
    if ($IncludeProcess) {
        Assert-EnvVar -Name $Name -Value $Value -Target Process
    }
}

#-------------------------------------------------------------------------------

function Assert-PathEnvVar {
    <#
        .SYNOPSIS
            Ensures the given path is included in the `Path` environment variable.

        .PARAMETER Path
            The path to be included in the `Path` environment variable.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Path
    )

    # Check if the given path is already in the environment variable
    $pathArray = $Env:Path -Split ';'
    if ($pathArray -NotContains $Path) {
        # If not, add it
        $name = 'Path'
        Write-Host "Adding '$Path' to environment variable '$name'"
        $pathArray += $Path
        $newPath = $pathArray -Join ';'
        [Environment]::SetEnvironmentVariable($name, $newPath, `
                [EnvironmentVariableTarget]::Machine)
        [Environment]::SetEnvironmentVariable($name, $newPath, `
                [EnvironmentVariableTarget]::Process)
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-EnvVar
Export-ModuleMember -Function Assert-PathEnvVar
