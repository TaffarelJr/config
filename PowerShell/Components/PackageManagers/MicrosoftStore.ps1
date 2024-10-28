"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Microsoft Store'
#-------------------------------------------------------------------------------

# Since we don't know what other package managers are available,
# use the bare PowerShell functions to install the app
Get-AppxPackage -AllUsers 'Microsoft.WindowsStore' | ForEach-Object {
    Write-host "Installing '$($_.Name)' ..."
    Add-AppxPackage -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction 'SilentlyContinue'
    Confirm-Installation -ScriptBlock { $_.Version }
}
