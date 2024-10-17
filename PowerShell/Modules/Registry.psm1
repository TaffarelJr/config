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

Export-ModuleMember -Function Backup-Registry
