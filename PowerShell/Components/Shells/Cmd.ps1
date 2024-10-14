"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'CMD.exe'
#-------------------------------------------------------------------------------

Write-Host 'Validating configuration ...'

# Set UTF-8 as default
# https://stackoverflow.com/a/57134096/4690597
Assert-RegistryValue `
    -Hive CurrentUser `
    -Key 'Software\Microsoft\Command Processor' `
    -ValueName 'AutoRun' `
    -ValueData 'chcp 65001 >NUL'
