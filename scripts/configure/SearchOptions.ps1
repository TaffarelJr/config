# Load supporting script files
Add-Type -Path ".\Microsoft.Search.Interop.dll"
. "..\Utilities.ps1"

$searchLocations = "C:\Code"

Write-Header "Configure Windows Search options"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\"
	Push-Location -Path ".\Preferences\"
		Write-Host "Include compressed files (ZIP, CAB...)"
		Set-ItemProperty -Path "." -Name "ArchivedFiles" -Type "DWord" -Value "1"
	Pop-Location

	Push-Location -Path ".\PrimaryProperties\UnindexedLocations\"
		Write-Host "Always search file names and contents"
		Set-ItemProperty -Path "." -Name "SearchOnly" -Type "DWord" -Value "0"
	Pop-Location
Pop-Location

Write-Host
Write-Host "Add Windows Search locations:"
$searchManager = New-Object Microsoft.Search.Interop.CSearchManagerClass
$searchCatalog = $searchManager.GetCatalog("SystemIndex")
$crawlManager = $searchCatalog.GetCrawlScopeManager()
Push-Indent
	foreach ($location in $searchLocations) {
		Write-Host (Add-Indent $location)
		$crawlManager.AddUserScopeRule("file:///$location", $true, $false, $null)
	}
Pop-Indent

$crawlManager.SaveAll()
