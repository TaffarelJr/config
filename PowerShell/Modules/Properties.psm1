function Assert-Property {
    <#
        .SYNOPSIS
            Ensures the specified property exists on the given object.

        .PARAMETER InputObject
            The object to be inspected.

        .PARAMETER Name
            The name of the property on the object to be inspected.

        .OUTPUTS
            $True if the property had to be created;
            or $False if the property already exists.
    #>

    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [PSObject] $InputObject,

        [Parameter(Position = 1, Mandatory)]
        [string] $Name
    )

    # Attempt to find the specified property on the given object
    $property = $InputObject `
    | Get-Member -MemberType NoteProperty `
    | Where-Object { $_.Name -eq $Name }

    # Create the property if it doesn't exist
    if (-not $property) {
        Write-Host "Creating property '$Name'"
        $InputObject | Add-Member `
            -MemberType NoteProperty `
            -Name $Name `
            -Value ([PSCustomObject]@{})

        return $True
    }

    # Otherwise, no changes were required
    return $False
}

#-------------------------------------------------------------------------------

function Assert-PropertyValue {
    <#
        .SYNOPSIS
            Ensures the specified property exists on the given object,
            and that it's set to the given value.

        .PARAMETER InputObject
            The object to be inspected.

        .PARAMETER Name
            The name of the property on the object to be inspected.

        .PARAMETER Value
            The value of the property on the object to be inspected.

        .OUTPUTS
            $True if the property had to be created or modified;
            or $False if the property already exists with the correct value.
    #>

    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [PSObject] $InputObject,

        [Parameter(Position = 1, Mandatory)]
        [string] $Name,

        [Parameter(Position = 2, Mandatory)]
        $Value
    )

    # Attempt to find the specified property on the given object
    $property = $InputObject `
    | Get-Member -MemberType NoteProperty `
    | Where-Object { $_.Name -eq $Name }

    # Create the property if it doesn't exist
    if (-not $property) {
        Write-Host "Creating property '$Name' with value '$Value'"
        $InputObject | Add-Member `
            -MemberType NoteProperty `
            -Name $Name `
            -Value $Value

        return $True
    }

    # Get the actual value of the specified property on the given object
    $currentValue = $InputObject | Select-Object -ExpandProperty $Name

    # Set the property value if it's incorrect
    if ($currentValue -ne $Value) {
        Write-Host "Setting property '$Name' to '$Value'"
        Invoke-Expression "`$InputObject.$Name = `$Value"
        return $True
    }

    # Otherwise, no changes were required
    return $False
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-Property
Export-ModuleMember -Function Assert-PropertyValue
