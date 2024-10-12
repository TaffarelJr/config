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

Export-ModuleMember -Function Backup-Registry
Export-ModuleMember -Function Assert-RegistryDrives
Export-ModuleMember -Function Assert-RegistryKey
