"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'WinGet'
#-------------------------------------------------------------------------------

# WinGet is included as part of the 'App Installer' app.
# Since we don't know what other package managers are available,
# use the bare PowerShell functions to install it.
Get-AppxPackage -AllUsers 'Microsoft.DesktopAppInstaller' | ForEach-Object {
    Write-host "Installing '$($_.Name)' ..."
    Add-AppxPackage -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction 'SilentlyContinue'
    Confirm-Installation -ScriptBlock { $_.Version }
}

# CLI and PowerShell module should also be available
Confirm-Installation -Label 'CLI' -ScriptBlock { winget -v }
Confirm-Installation -Label 'PowerShell module' -ScriptBlock { Get-WinGetVersion }

Assert-WinGetSource `
    -Name 'winget' `
    -Uri 'https://cdn.winget.microsoft.com/cache' `
    -Type 'Microsoft.PreIndexed.Package'

Assert-WinGetSource `
    -Name 'msstore' `
    -Uri 'https://storeedgefd.dsx.mp.microsoft.com/v9.0' `
    -Type 'Microsoft.Rest'
