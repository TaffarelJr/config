"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Webex'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Cisco.Webex'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'Webex'

# Prevent auto-startup
Remove-FromWindowsStartup -Name 'CiscoSpark'
Remove-FromWindowsStartup -Name 'CiscoMeetingDaemon'
