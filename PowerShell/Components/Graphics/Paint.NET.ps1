"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Paint.NET'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'dotPDN.PaintDotNet'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'paint.net'
