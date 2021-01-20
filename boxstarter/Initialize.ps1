#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Download & import utilities
$uri = "https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Utilities.ps1"
$filePath = "$Env:TEMP\Utilities.ps1"
Write-Host "Download & import $uri"
Invoke-WebRequest -Uri $uri -OutFile $filePath -UseBasicParsing
. $filePath

#----------------------------------------------------------------------------------------------------
Write-Header "Rename computer"
#----------------------------------------------------------------------------------------------------

# Prompt the user
Write-Host "Computer name is: $Env:COMPUTERNAME"
Write-Host "What would you like to rename it to?"
$computerName = Read-Host -Prompt "<press ENTER to skip>"

# Rename the computer only if the user provided a new name
if ($computerName.Length -gt 0) {
    Rename-Computer -NewName $computerName
} else {
    Write-Host "Skipping ..."
}

#----------------------------------------------------------------------------------------------------
Write-Header "Disable uneeded services"
#----------------------------------------------------------------------------------------------------

# Security risk; Microsoft recommends removing immediately, to avoid ransomware attacks
# https://www.tenforums.com/tutorials/107605-enable-disable-smb1-file-sharing-protocol-windows.html
Write-Host "Disable SMB1Protocol due to security risk ... " -NoNewline
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart
Write-Host "Done"

# Unneeded services
@(
    "lmhosts"  # Don't need NetBIOS over TCP/IP
    "SNMPTRAP" # Don't need SNMP
    "TapiSrv"  # Don't need Telephony API
) | Disable-WindowsService

#----------------------------------------------------------------------------------------------------
Write-Header "Remove bloatware" # so we don't update them later
#----------------------------------------------------------------------------------------------------

# Unwanted Windows Store Apps
@(
    "*HiddenCity*"
    "*iHeartRadio*"
    "*McAfee*"
    "*Netflix*"
    "*Twitter*"
    "Adobe*"
    "Dell*"
    "Dolby*"
    "Facebook*"
    "Flipboard*"
    "Hulu*"
    "king.com*"
    "Microsoft.3DBuilder*"
    "Microsoft.Bing*"
    "Microsoft.FreshPaint*"
    "Microsoft.GetHelp*"
    "Microsoft.Getstarted*"
    "Microsoft.Messaging*"
    "Microsoft.Microsoft3DViewer*"
    "Microsoft.MicrosoftOfficeHub*"
    "Microsoft.MicrosoftSolitaireCollection*"
    "Microsoft.Minecraft*"
    "Microsoft.MixedReality.Portal*"
    "Microsoft.MSPaint*"
    "Microsoft.NetworkSpeedTest*"
    "Microsoft.Office.OneNote*"
    "Microsoft.Office.Sway*"
    "Microsoft.OneConnect*"
    "Microsoft.Print3D*"
    "Microsoft.SkypeApp*"
    "Microsoft.WindowsAlarms*"
    "Microsoft.WindowsFeedbackHub*"
    "Microsoft.WindowsMaps*"
    "Microsoft.WindowsPhone*"
    "Microsoft.WindowsSoundRecorder*"
    "Microsoft.XboxApp*"
    "Microsoft.XboxIdentityProvider*"
    "Microsoft.Zune*"
    "Pandora*"
    "Roblox*"
    "Spotify*"
) | Remove-WindowsStoreApp

# McAfee
$mcafee = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | `
    ForEach-Object { Get-ItemProperty $_.PSPath } | `
    Where-Object { $_ -match "McAfee Security" } | `
    Select-Object UninstallString
if ($mcafee) {
    $mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe", ""
    Write-Host "Uninstalling McAfee..." -NoNewline
    start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
    Write-Host "Done"
}

#----------------------------------------------------------------------------------------------------
Write-Header "Install Windows updates" # so everything's current
#----------------------------------------------------------------------------------------------------

Install-WindowsUpdate -AcceptEula

# async - not blocking
Write-Host "Update Windows Store applications"
(Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" -Class "MDM_EnterpriseModernAppManagement_AppManagement01").UpdateScanMethod()

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Windows Explorer"
#----------------------------------------------------------------------------------------------------

Write-Host "Standard settings ... " -NoNewline
Set-WindowsExplorerOptions `
    -DisableOpenFileExplorerToQuickAccess `
    -EnableShowRecentFilesInQuickAccess `
    -EnableShowFrequentFoldersInQuickAccess `
    -EnableShowFullPathInTitleBar `
    -EnableShowHiddenFilesFoldersDrives `
    -EnableShowFileExtensions `
    -DisableShowProtectedOSFiles `
    -EnableExpandToOpenFolder `
    -EnableShowRibbon `
    -EnableSnapAssist
Write-Host "Done"

Write-Host "Advanced settings ... " -NoNewline
Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\"; & {
    Push-Location -Path ".\Advanced\"; & {
        Set-ItemProperty -Path "." -Name "HideDrivesWithNoMedia"      -Type "DWord" -Value "0" # Show empty drives
        Set-ItemProperty -Path "." -Name "HideMergeConflicts"         -Type "DWord" -Value "0" # Show folder merge conflicts
        Set-ItemProperty -Path "." -Name "SeparateProcess"            -Type "DWord" -Value "1" # Launch folder windows in a separate process
        Set-ItemProperty -Path "." -Name "PersistBrowsers"            -Type "DWord" -Value "1" # Restore previous folder windows at logon
        Set-ItemProperty -Path "." -Name "ShowEncryptCompressedColor" -Type "DWord" -Value "1" # Show encrypted or compressed NTFS files in color
        Set-ItemProperty -Path "." -Name "NavPaneShowAllFolders"      -Type "DWord" -Value "1" # Show all folders
    }; Pop-Location
    Push-Location -Path ".\Search\"; & {
        Set-ItemProperty -Path ".\Preferences\"                          -Name "ArchivedFiles" -Type "DWord" -Value "1" # Include compressed files (ZIP, CAB...)
        Set-ItemProperty -Path ".\PrimaryProperties\UnindexedLocations\" -Name "SearchOnly"    -Type "DWord" -Value "0" # Always search file names and contents
    }; Pop-Location
}; Pop-Location
Write-Host "Done"

Write-Host "Disable Bing in Search box ... " -NoNewline
Disable-BingSearch
Write-Host "Done"

#----------------------------------------------------------------------------------------------------
Write-Header "Disable Xbox Game Bar"
#----------------------------------------------------------------------------------------------------

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type "DWord" -Value "0"
Set-ItemProperty -Path "HKCU:\System\GameConfigStore"                            -Name "GameDVR_Enabled"   -Type "DWord" -Value "0"

Disable-GameBarTips

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Windows Search file extensions"
#----------------------------------------------------------------------------------------------------

@(
    ".accessor", ".application", ".appref-ms", ".asmx",
    ".cake", ".cd", ".cfg", ".cmproj", ".cmpuo", ".config", ".csdproj", ".csx",
    ".datasource", ".dbml", ".dependencies", ".disco", ".dotfuproj",
    ".gitattributes", ".gitignore", ".gitmodules",
    ".jshtm", ".json", ".jsx",
    ".lock", ".log",
    ".md", ".myapp",
    ".nuspec",
    ".proj", ".ps1", ".psm1",
    ".rdl", ".references", ".resx",
    ".settings", ".sln", ".stvproj", ".suo", ".svc",
    ".testrunconfig", ".text", ".tf", ".tfstate", ".tfvars",
    ".vb", ".vbdproj", ".vddproj", ".vdp", ".vdproj", ".vscontent", ".vsmdi", ".vssettings",
    ".wsdl",
    ".yaml", ".yml",
    ".xaml", ".xbap", ".xproj"
) | Set-WindowsSearchFileExtension

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Group Policy settings (Windows 10 Pro only)"
#----------------------------------------------------------------------------------------------------

Push-Location -Path "HKLM:\SOFTWARE\Policies\Microsoft\"; & {
    # Microsoft OneDrive
    $regPath = ".\Windows\OneDrive\"
    if (Test-Path $regPath) {
        Write-Host "Unlock Microsoft OneDrive ... " -NoNewline
        Push-Location -Path $regPath; & {
            Set-ItemProperty -Path "." -Name "DisableFileSync"     -Type "DWord" -Value "0" # Enable file sync
            Set-ItemProperty -Path "." -Name "DisableFileSyncNGSC" -Type "DWord" -Value "0" # Enable file sync (next-gen)
        }; Pop-Location
        Write-Host "Done"
    }

    # Windows Store
    $regPath = ".\WindowsStore\"
    if (Test-Path $regPath) {
        Write-Host "Unlock Windows Store ... " -NoNewline
        Push-Location -Path $regPath; & {
            Set-ItemProperty -Path "." -Name "DisableStoreApps"        -Type "DWord" -Value "0" # Enable Store apps
            Set-ItemProperty -Path "." -Name "RemoveWindowsStore"      -Type "DWord" -Value "0" # Do not remove Windows Store
            Set-ItemProperty -Path "." -Name "RequirePrivateStoreOnly" -Type "DWord" -Value "0" # Do not require private Store only
        }; Pop-Location
        Write-Host "Done"
    }
}; Pop-Location

#----------------------------------------------------------------------------------------------------
Write-Header "Move library folders to OneDrive"
#----------------------------------------------------------------------------------------------------

Move-LibraryDirectory -libraryName "Desktop"     -newPath "$Env:OneDrive\Desktop"
RefreshEnv
Move-LibraryDirectory -libraryName "Downloads"   -newPath "$Env:OneDrive\Downloads"
RefreshEnv
Move-LibraryDirectory -libraryName "My Music"    -newPath "$Env:OneDrive\Music"
RefreshEnv
Move-LibraryDirectory -libraryName "My Pictures" -newPath "$Env:OneDrive\Pictures"
RefreshEnv
Move-LibraryDirectory -libraryName "My Video"    -newPath "$Env:OneDrive\Videos"
RefreshEnv
Move-LibraryDirectory -libraryName "Personal"    -newPath "$Env:OneDrive\Documents"
RefreshEnv

#----------------------------------------------------------------------------------------------------
Write-Header "Clean up default desktop shortcuts"
#----------------------------------------------------------------------------------------------------

Write-Host "Microsoft Edge"
Remove-Item "$Env:PUBLIC\Desktop\Microsoft Edge.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
