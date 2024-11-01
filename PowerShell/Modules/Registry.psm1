using namespace Microsoft.Win32

#-------------------------------------------------------------------------------

$hives = @(
    [PSCustomObject]@{Hive = [RegistryHive]::ClassesRoot; Name = 'HKEY_CLASSES_ROOT'; Short = 'HKCR' },
    [PSCustomObject]@{Hive = [RegistryHive]::CurrentConfig; Name = 'HKEY_CURRENT_CONFIG'; Short = 'HKCC' },
    [PSCustomObject]@{Hive = [RegistryHive]::CurrentUser; Name = 'HKEY_CURRENT_USER'; Short = 'HKCU' },
    [PSCustomObject]@{Hive = [RegistryHive]::LocalMachine; Name = 'HKEY_LOCAL_MACHINE'; Short = 'HKLM' },
    [PSCustomObject]@{Hive = [RegistryHive]::Users; Name = 'HKEY_USERS'; Short = 'HKU' }
)

#-------------------------------------------------------------------------------

function Backup-Registry {
    <#
        .SYNOPSIS
            Prompts the user to take a snapshot of the current registry settings.
    #>

    Write-Host 'Take a snapshot of the current registry settings?'
    Write-Host '(Files will be saved to the desktop.)'
    $y = Read-Host '<type [y|yes]; any other key to skip>'

    if (($y -eq 'y') -or ($y -eq 'yes')) {
        $path = [Environment]::GetFolderPath('Desktop')
        $timestamp = Get-Date -Format 'yyyy-MM-dd-HH-mm-ss'

        $hives | ForEach-Object {
            Write-Host "Backing up $($_.Name) to '$path' ..."
            reg export $_.Short "$path\$timestamp`_$($_.Short).reg" /y
        }
    }
}

#-------------------------------------------------------------------------------

function Assert-RegistryDrives {
    <#
        .SYNOPSIS
            Ensures all registry hives have a mapped PSDrive,
            to make them accessible.
    #>

    $hives | ForEach-Object {
        if (-not (Get-PSDrive -Name $_.Short -ErrorAction 'SilentlyContinue')) {
            Write-Host "Mapping PSDrive to $($_.Name)"
            New-PSDrive -Name $_.Short -PSProvider 'Registry' -Root $_.Name -Scope 'Global' | Out-Null
        }
    }
}

#-------------------------------------------------------------------------------

function Assert-RegistryKey {
    <#
        .SYNOPSIS
            Ensures a registry key exists, creating it if necessary.

        .PARAMETER Hive
            The registry hive to which the key belongs.

        .PARAMETER Key
            The registry key path (excluding the hive).

        .OUTPUTS
            The registry key object, in a writable state.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [RegistryHive] $Hive,

        [Parameter(Position = 1, Mandatory)]
        [string] $Key
    )

    # Open the registry key
    $hiveKey = [RegistryKey]::OpenBaseKey($Hive, [RegistryView]::Default)
    $registryKey = $hiveKey.OpenSubKey($Key, $true) # Writable
    if ($null -eq $registryKey) {
        # If it doesn't exist, create it
        Write-Host "Creating registry key '$($Hive.ToString()):\$Key'"
        $registryKey = $hiveKey.CreateSubKey($Key, $true) # Writable
    }

    return $registryKey
}

#-------------------------------------------------------------------------------

function Assert-RegistryValue {
    <#
        .SYNOPSIS
            Ensures a registry value exists, creating it if necessary.

        .PARAMETER Hive
            The registry hive to which the key belongs.

        .PARAMETER Key
            The registry key path (excluding the hive).

        .PARAMETER ValueName
            The name of the registry value.
            Passing $null or an empty string will set the default value.
            Optional. Defaults to $null.

        .PARAMETER ValueData
            The data for the registry value.

        .PARAMETER ValueType
            The data type of the registry value.
            Optional. Defaults to 'String'.

        .PARAMETER CreateOnly
            If specified, the value is only set if it doesn't already exist.
            If it already exists, the value is not modified.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [RegistryHive] $Hive,

        [Parameter(Position = 1, Mandatory)]
        [string] $Key,

        [Parameter(Position = 2)]
        [string] $ValueName = $null,

        [Parameter(Position = 3, Mandatory)]
        $ValueData,

        [Parameter(Position = 4)]
        [RegistryValueKind] $ValueType = [RegistryValueKind]::String,

        [Parameter(Position = 5)]
        [switch] $CreateOnly
    )

    # Get the current data in the registry value
    $registryKey = Assert-RegistryKey -Hive $Hive -Key $Key
    $currentValue = $registryKey.GetValue($ValueName, $null, `
            [RegistryValueOptions]::DoNotExpandEnvironmentNames)

    # Set the registry value data, if necessary
    if ($null -eq $currentValue) {
        Write-Host "Creating registry value '$ValueName' set to '$ValueData' ($ValueType)"
        $registryKey.SetValue($ValueName, (Convert $ValueData $ValueType), $ValueType)
    }
    elseif ((-not $CreateOnly) -and ($currentValue -cne $ValueData)) {
        Write-Host "Setting registry value '$ValueName' to '$ValueData' ($ValueType)"
        $registryKey.SetValue($ValueName, (Convert $ValueData $ValueType), $ValueType)
    }

    # Flush changes
    $registryKey.Close()
}

#-------------------------------------------------------------------------------

function Remove-RegistryKey {
    <#
        .SYNOPSIS
            Ensures a registry key is removed.

        .PARAMETER Hive
            The registry hive to which the key belongs.

        .PARAMETER Key
            The registry key path (excluding the hive).
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [RegistryHive] $Hive,

        [Parameter(Position = 1, Mandatory)]
        [string] $Key
    )

    # Check if the registry key exists
    $hiveKey = [RegistryKey]::OpenBaseKey($Hive, [RegistryView]::Default)
    $registryKey = $hiveKey.OpenSubKey($Key, $false) # Read-only
    if ($null -ne $registryKey) {
        # If so, delete it
        Write-Host "Deleting registry key '$($Hive.ToString()):\$Key'"
        $hiveKey.DeleteSubKeyTree($Key)
    }
}

#-------------------------------------------------------------------------------

function Remove-RegistryValue {
    <#
        .SYNOPSIS
            Ensures a registry value is removed.

        .PARAMETER Hive
            The registry hive to which the key belongs.

        .PARAMETER Key
            The registry key path (excluding the hive).

        .PARAMETER ValueName
            The name of the registry value.
            Optional. Defaults to '(Default)'.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [RegistryHive] $Hive,

        [Parameter(Position = 1, Mandatory)]
        [string] $Key,

        [Parameter(Position = 2)]
        [string] $ValueName = '(Default)'
    )

    # Check if the registry key exists
    $hiveKey = [RegistryKey]::OpenBaseKey($Hive, [RegistryView]::Default)
    $registryKey = $hiveKey.OpenSubKey($Key, $true) # Writable
    if ($null -ne $registryKey) {
        # If so, check if the registry value exists
        $currentValue = $registryKey.GetValue($ValueName, $null);
        if ($null -ne $currentValue) {
            # If so, delete it
            Write-Host "Deleting registry value '$ValueName'"
            $registryKey.DeleteValue($ValueName)

            # Flush changes
            $registryKey.Close()
        }
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Backup-Registry
Export-ModuleMember -Function Assert-RegistryDrives
Export-ModuleMember -Function Assert-RegistryKey
Export-ModuleMember -Function Assert-RegistryValue
Export-ModuleMember -Function Remove-RegistryKey
Export-ModuleMember -Function Remove-RegistryValue

# Private helper functions:
#-------------------------------------------------------------------------------

function Convert {
    param(
        [Parameter(Position = 0, Mandatory)]
        $ValueData,

        [Parameter(Position = 1, Mandatory)]
        [RegistryValueKind] $ValueType
    )

    switch ($ValueType) {
        Binary {
            # Hexadecimal string: 2 chars = 1 byte
            $binary = [byte[]]::new($ValueData.Length / 2)
            for ($i = 0; $i -lt $ValueData.Length; $i += 2) {
                $binary[$i / 2] = [Convert]::ToByte($ValueData.Substring($i, 2), 16)
            }
            return $binary
        }

        DWord { return [Convert]::ToInt32($ValueData) }
        QWord { return [Convert]::ToInt64($ValueData) }
        MultiString { return ($ValueData -Split "`n") }
        default { return $ValueData }
    }
}
