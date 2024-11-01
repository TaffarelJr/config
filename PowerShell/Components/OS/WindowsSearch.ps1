using namespace Microsoft.Win32

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Windows Search'
#-------------------------------------------------------------------------------

Write-Host 'Validating configuration ...'

# Windows Explorer -> Options -> Search
$hive = [RegistryHive]::CurrentUser
$key = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences'
Assert-RegistryValue $hive $key 'WholeFileSystem' 0 DWord # Don't use the index when searching in file folders for system files (searches might take longer)
Assert-RegistryValue $hive $key 'SystemFolders'   1 DWord # Include system directories
Assert-RegistryValue $hive $key 'ArchivedFiles'   1 DWord # Include compressed files (ZIP,CAB...)
$key = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Search\PrimaryProperties\UnindexedLocations'
Assert-RegistryValue $hive $key 'SearchOnly'      1 DWord # Always search file names and contents (this might take several minutes)

# Indexing Options -> Index these locations:
@(
    'C:\Users'
) | Assert-WindowsSearchLocation

# Indexing Options -> Advanced -> File Types
@(
    '.accessor', '.application', '.appref-ms', '.asmx',
    '.cake', '.cd', '.cfg', '.cmproj', '.cmpuo', '.config', '.csdproj', '.csx',
    '.datasource', '.dbml', '.dependencies', '.disco', '.dotfuproj',
    '.gitattributes', '.gitignore', '.gitmodules',
    '.jshtm', '.json', '.jsx',
    '.lock', '.log',
    '.md', '.myapp',
    '.nuspec',
    '.proj', '.props', '.ps1', '.psm1',
    '.rdl', '.references', '.resx',
    '.settings', '.sln', '.stvproj', '.suo', '.svc',
    '.testrunconfig', '.testsettings', '.text', '.tf', '.tfstate', '.tfvars',
    '.vb', '.vbdproj', '.vddproj', '.vdp', '.vdproj', '.vscontent', '.vsmdi', '.vssettings',
    '.wsdl',
    '.xaml', '.xbap', '.xproj',
    '.yaml', '.yml'
) | Assert-WindowsSearchContents
