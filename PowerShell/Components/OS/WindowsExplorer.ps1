using namespace Microsoft.Win32

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Windows Explorer'
#-------------------------------------------------------------------------------

Write-Host 'Validating configuration ...'

# Windows Explorer -> Options -> View -> Advanced Settings
$hive = [RegistryHive]::CurrentUser
$key = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Assert-RegistryValue $hive $key 'IconsOnly'                      0 DWord # Always show icons, never thumbnails
Assert-RegistryValue $hive $key 'UseCompactMode'                 0 DWord # Decrease space between items (compact view)
Assert-RegistryValue $hive $key 'ShowTypeOverlay'                1 DWord # Display file icon on thumbnails
Assert-RegistryValue $hive $key 'FolderContentsInfoTip'          1 DWord # Display file size information in folder tips
$key = 'Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'
Assert-RegistryValue $hive $key 'FullPath'                       0 DWord # Display the full path in the title bar
$key = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Assert-RegistryValue $hive $key 'Hidden'                         1 DWord # Show hidden files, folders, and drives
Assert-RegistryValue $hive $key 'HideDrivesWithNoMedia'          0 DWord # Hide empty drives
Assert-RegistryValue $hive $key 'HideFileExt'                    0 DWord # Hide extensions for known file types
Assert-RegistryValue $hive $key 'HideMergeConflicts'             0 DWord # Hide folder merge conflicts
Assert-RegistryValue $hive $key 'ShowSuperHidden'                1 DWord # Hide protected operating system files (Recommended)
Assert-RegistryValue $hive $key 'SeparateProcess'                1 DWord # Launch folder windows in a separate process
Assert-RegistryValue $hive $key 'PersistBrowsers'                1 DWord # Restore previous folder windows at logon
Assert-RegistryValue $hive $key 'ShowDriveLettersFirst'          0 DWord # Show drive letters
Assert-RegistryValue $hive $key 'ShowEncryptCompressedColor'     1 DWord # Show encrypted or compressed NTFS files in color
Assert-RegistryValue $hive $key 'ShowInfoTip'                    1 DWord # Show pop-up description for folder and desktop items
Assert-RegistryValue $hive $key 'ShowPreviewHandlers'            1 DWord # Show preview handlers in preview pane
Assert-RegistryValue $hive $key 'ShowStatusBar'                  1 DWord # Show status bar
Assert-RegistryValue $hive $key 'ShowSyncProviderNotifications'  1 DWord # Show sync provider notifications
Assert-RegistryValue $hive $key 'AutoCheckSelect'                0 DWord # Use check boxes to select items
Assert-RegistryValue $hive $key 'SharingWizardOn'                1 DWord # Use Sharing Wizard (Recommended)
Assert-RegistryValue $hive $key 'TypeAhead'                      0 DWord # Select the typed item in the view
Assert-RegistryValue $hive $key 'NavPaneShowAllCloudStates'      1 DWord # Always show availability status
Assert-RegistryValue $hive $key 'NavPaneExpandToCurrentFolder'   1 DWord # Expand to open folder
Assert-RegistryValue $hive $key 'NavPaneShowAllFolders'          0 DWord # Show all folders
$key = 'Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}'
Assert-RegistryValue $hive $key 'System.IsPinnedToNameSpaceTree' 0 DWord # Show libraries
$key = 'Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'
Assert-RegistryValue $hive $key 'System.IsPinnedToNameSpaceTree' 1 DWord # Show Network
$key = 'Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
Assert-RegistryValue $hive $key 'System.IsPinnedToNameSpaceTree' 1 DWord # Show This PC
