# Load supporting script files
Add-Type -Path ".\Microsoft.Search.Interop.dll"
. ".\Utilities.ps1"

$searchLocations = "C:\Code"
$indexExtensions = `
	".accessor", ".application", ".appref-ms", ".asmx", `
	".cake", ".cd", ".cfg", ".cmproj", ".cmpuo", ".config", ".csdproj", ".csx", `
	".datasource", ".dbml", ".dependencies", ".disco", ".dotfuproj", `
	".gitattributes", ".gitignore", ".gitmodules", `
	".jshtm", ".json", ".jsx", `
	".lock", ".log", `
	".md", ".myapp", `
	".nuspec", `
	".proj", ".ps1", ".psm1", `
	".rdl", ".references", ".resx", `
	".settings", ".sln", ".stvproj", ".suo", ".svc", `
	".testrunconfig", ".text", ".tf", ".tfstate", ".tfvars", `
	".vb", ".vbdproj", ".vddproj", ".vdp", ".vdproj", ".vscontent", ".vsmdi", ".vssettings", `
	".wsdl", `
	".yaml", ".yml", `
	".xaml", ".xbap", ".xproj"


Write-Header "Configure Windows Search options"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\"

Write-Host "Include compressed files (ZIP, CAB...) ..."
Push-Location -Path ".\Preferences\"
Set-ItemProperty -Path "." -Name "ArchivedFiles" -Type "DWord" -Value "1"
Pop-Location

Write-Host "Always search file names and contents ..."
Push-Location -Path ".\PrimaryProperties\UnindexedLocations\"
Set-ItemProperty -Path "." -Name "SearchOnly" -Type "DWord" -Value "0"
Pop-Location

Pop-Location

Write-Host "Search contents of files with extensions:"
New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null
Push-Location -Path "HKCR:\"
Push-Indent

foreach ($extension in $indexExtensions) {
	Write-Host (Add-Indent "$extension ...")
	Push-Location -Path ".\$extension\PersistentHandler\"
	Set-ItemProperty -Path "." -Name "(Default)" -Type "String" -Value "{5E941D80-BF96-11CD-B579-08002B30BFEB}"
	Set-ItemProperty -Path "." -Name "OriginalPersistentHandler" -Type "String" -Value "{00000000-0000-0000-0000-000000000000}"
	Pop-Location
}

Pop-Indent
Pop-Location

Write-Host "Adding Windows Search locations ..."
$searchManager = New-Object Microsoft.Search.Interop.CSearchManagerClass
$searchCatalog = $searchManager.GetCatalog("SystemIndex")
$crawlManager = $searchCatalog.GetCrawlScopeManager()
Push-Indent

foreach ($location in $searchLocations) {
	Write-Host (Add-Indent "$location ...")
	$crawlManager.AddUserScopeRule("file:///$location", $true, $false, $null)
}

Pop-Indent
$crawlManager.SaveAll()
Write-Host "Done"
