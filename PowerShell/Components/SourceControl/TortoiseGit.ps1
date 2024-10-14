using namespace Microsoft.Win32

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'TortoiseGit'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'TortoiseGit.TortoiseGit'

# Configuration settings -> General
$hive = [RegistryHive]::CurrentUser
$key = 'Software\TortoiseGit'
Assert-RegistryValue $hive $key 'ContextMenuEntrieshigh'              16777248 DWord # Context Menu (default + Revision Graph)
Assert-RegistryValue $hive $key 'ContextMenuExtEntriesLow'          1073741824 DWord # Context Menu 2 (default)
Assert-RegistryValue $hive $key 'ContextMenu11Entries'     2377918435981463702 QWord # Windows 11 Context Menu (default + Revision Graph)
