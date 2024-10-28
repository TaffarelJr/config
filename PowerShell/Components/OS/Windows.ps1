"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Windows'
#-------------------------------------------------------------------------------

# Security risk; Microsoft recommends removing immediately to avoid ransomware attacks
# https://www.tenforums.com/tutorials/107605-enable-disable-smb1-file-sharing-protocol-windows.html
Write-Host "Disabling SMB1Protocol due to security risk"
Disable-WindowsOptionalFeature -FeatureName 'SMB1Protocol' -Online -NoRestart

# https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation
Write-Host 'Enabling long path support'
Assert-RegistryValue `
    -Hive LocalMachine `
    -Key 'SYSTEM\CurrentControlSet\Control\FileSystem' `
    -ValueName 'LongPathsEnabled' `
    -ValueData 1 `
    -ValueType DWord
