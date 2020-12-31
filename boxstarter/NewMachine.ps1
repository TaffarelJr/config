# Boxstarter Script to apply standard configuration and install common applications.
# https://boxstarter.org/
#
# Install Boxstarter:
# 	. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# Set: Set-ExecutionPolicy RemoteSigned
# Then: Install-BoxstarterPackage -PackageName <URL-TO-RAW-OR-GIST> -DisableReboots
#
# Pulled from samples by:
# - Microsoft https://github.com/Microsoft/windows-dev-box-setup-scripts
# - elithrar https://github.com/elithrar/dotfiles
# - jessfraz https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
# - NickCraver https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

$unwantedApps = @(
    "*BubbleWitch*"
    "*CandyCrush*"
    "*Dell*"
    "*Facebook*"
    "*Flipboard*"
    "*iHeartRadio*"
    "*McAfee*"
    "*Minecraft*"
    "*Netflix*"
    "*Shazam*"
    "*Twitter*"
    "Microsoft.3DBuilder"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    "Microsoft.FreshPaint"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.XboxApp"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)

$indexExtensions = @(
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
)

# Pre
Disable-UAC

# Prompt the user to pick a name for the computer
Write-Host "Computer name is: $env:computername"
Write-Host "What would you like to rename it to?"
$computerName = Read-Host -Prompt "<press ENTER to skip>"
if ($computerName.Length -gt 0) { Rename-Computer -NewName $computerName }

# Install Windows Updates
Install-WindowsUpdate -AcceptEula

# Remove bloatware
Write-Host "Remove Windows Bloatware"
foreach ($app in $unwantedApps) {
    Write-Host "    $app"
    $ProgressPreference = "SilentlyContinue" # Need to hide the progress bar as otherwise it remains on the screen
    Get-AppxPackage $app -AllUsers | Remove-AppxPackage
    $ProgressPreference = "Continue"
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online
    $appPath = "$Env:LOCALAPPDATA\Packages\$app*"
    Remove-Item $appPath -Recurse -Force -ErrorAction 0
}

# Configure Windows Explorer
Write-Host "Configure Windows Explorer"
Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"; & {
    Set-ItemProperty -Path "." -Name "Hidden"                     -Type "DWord" -Value "1" # Show hidden files, folders, and drives
    Set-ItemProperty -Path "." -Name "HideDrivesWithNoMedia"      -Type "DWord" -Value "0" # Show empty drives
    Set-ItemProperty -Path "." -Name "HideFileExt"                -Type "DWord" -Value "0" # Show extensions for known file types
    Set-ItemProperty -Path "." -Name "HideMergeConflicts"         -Type "DWord" -Value "0" # Show folder merge conflicts
    Set-ItemProperty -Path "." -Name "PersistBrowsers"            -Type "DWord" -Value "1" # Restore previous folder windows at logon
    Set-ItemProperty -Path "." -Name "SeparateProcess"            -Type "DWord" -Value "1" # Launch folder windows in a separate process
    Set-ItemProperty -Path "." -Name "ShowEncryptCompressedColor" -Type "DWord" -Value "1" # Show encrypted or compressed NTFS files in color
}; Pop-Location

# Configure Windows Search file extensions
Write-Host "Configure Windows Search file extensions"
New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null
Push-Location -Path "HKCR:\"; & {
    foreach ($extension in $indexExtensions) {
        Write-Host "    $extension"
        $regPath = "HKCR:\$extension\PersistentHandler\"
        New-Item $regPath -Force | Out-Null
        Push-Location -Path $regPath; & {
            Set-ItemProperty -Path "." -Name "(Default)"                 -Type "String" -Value "{5E941D80-BF96-11CD-B579-08002B30BFEB}"
            Set-ItemProperty -Path "." -Name "OriginalPersistentHandler" -Type "String" -Value "{00000000-0000-0000-0000-000000000000}"
        }; Pop-Location
    }
}; Pop-Location

# Configure Windows Search options
Write-Host "Configure Windows Search options"
Push-Location -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Search\"; & {
    Push-Location -Path ".\Preferences\"; & {
        Set-ItemProperty -Path "." -Name "ArchivedFiles" -Type "DWord" -Value "1" # Include compressed files (ZIP, CAB...)
    }; Pop-Location

    Push-Location -Path ".\PrimaryProperties\UnindexedLocations\"; & {
        Set-ItemProperty -Path "." -Name "SearchOnly" -Type "DWord" -Value "0" # Always search file names and contents
    }; Pop-Location
}; Pop-Location

# Unlock Microsoft OneDrive (Windows 10 Pro only)
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive\"
if (Test-Path $regPath) {
    Write-Host "Unlock Microsoft OneDrive"
    Push-Location -Path $regPath; & {
        Set-ItemProperty -Path "." -Name "DisableFileSync"     -Type "DWord" -Value "0" # Enable file sync
        Set-ItemProperty -Path "." -Name "DisableFileSyncNGSC" -Type "DWord" -Value "0" # Enable file sync (next-gen)
    }; Pop-Location
}

# Move 'Downloads' folder to OneDrive
Move-LibraryDirectory "Downloads" "$env:UserProfile\OneDrive\Downloads"

# Install browsers
choco install -y googlechrome
Remove-Item "C:\Users\Public\Desktop\Google Chrome.lnk"

# Install utilities
choco install -y 7zip
choco install -y ccleaner
Remove-Item "C:\Users\Public\Desktop\CCleaner.lnk"
choco install -y defraggler
Remove-Item "C:\Users\Public\Desktop\Defraggler.lnk"
choco install -y notepadplusplus
choco install -y spacesniffer

# Install additional cloud storage providers
choco install -y dropbox
choco install -y google-backup-and-sync
Remove-Item "C:\Users\Public\Desktop\Google Docs.lnk"
Remove-Item "C:\Users\Public\Desktop\Google Sheets.lnk"
Remove-Item "C:\Users\Public\Desktop\Google Slides.lnk"

# Install communications tools
choco install -y slack
choco install -y zoom
Remove-Item "C:\Users\Public\Desktop\Zoom.lnk"

# Install graphics tools
choco install -y paint.net
Remove-Item "C:\Users\Public\Desktop\paint.net.lnk"

# Unlock Windows Store
Write-Host "Unlock Windows Store"
Push-Location -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore\"; & {
    Set-ItemProperty -Path "." -Name "DisableStoreApps"        -Type "DWord" -Value "0" # Enable Store apps
    Set-ItemProperty -Path "." -Name "RemoveWindowsStore"      -Type "DWord" -Value "0" # Do not remove Windows Store
    Set-ItemProperty -Path "." -Name "RequirePrivateStoreOnly" -Type "DWord" -Value "0" # Do not require private Store only
}; Pop-Location

# Post
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
