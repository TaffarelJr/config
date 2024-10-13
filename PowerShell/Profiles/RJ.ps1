"$PSScriptRoot\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Profile: RJ'
#-------------------------------------------------------------------------------

# Configuration Settings:

$devDrive = 'C:\Dev'

$devFont = [PSCustomObject]@{
    Name    = 'FiraCode NF'
    Package = 'firacodenf'
}

#-------------------------------------------------------------------------------
Start-Component 'Windows Search'
#-------------------------------------------------------------------------------

# Indexing Options -> Index these locations:
Assert-WindowsSearchLocation -Path $devDrive

#-------------------------------------------------------------------------------
Start-Component 'Fonts'
#-------------------------------------------------------------------------------

Assert-ChocolateyPackage -Name $devFont.Package

#-------------------------------------------------------------------------------
Start-Component 'Windows Terminal'
#-------------------------------------------------------------------------------

Write-Host 'Validating configuration ...'
$config = Get-WindowsTerminalConfig

$changed = `
($config.profiles.defaults | Assert-Property -Name 'font') -bor `
($config.profiles.defaults.font | Assert-PropertyValue -Name 'face' -Value $devFont.Name) -bor `
($config.profiles.defaults.font | Assert-PropertyValue -Name 'size' -Value 11) -bor `
($config.profiles.defaults.font | Assert-PropertyValue -Name 'weight' -Value 'normal') -bor `
($config.profiles.defaults | Assert-PropertyValue -Name 'useAcrylic' -Value $True) -bor `
($config.profiles.defaults | Assert-PropertyValue -Name 'opacity' -Value 80)

if ($changed) {
    Write-Host 'Saving changes...'
    Set-WindowsTerminalConfig $config
}
