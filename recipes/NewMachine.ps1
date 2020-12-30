# Get the base URI path from the ScriptToCall value
$bstrapPackageFlag = "-bootstrapPackage"
$scriptUri = $Boxstarter['ScriptToCall']
$strpos = $scriptUri.IndexOf($bstrapPackageFlag)
$scriptUri = $scriptUri.Substring($strpos + $bstrapPackageFlag.Length)
$scriptUri = $scriptUri.TrimStart("'", " ")
$scriptUri = $scriptUri.TrimEnd("'", " ")
$scriptUri = $scriptUri.Substring(0, $scriptUri.LastIndexOf("/"))
$scriptUri += "/scripts"
Write-Host "Script base URI is '$scriptUri'"

function Invoke-Script {
    param ([string]$script)
    Invoke-Expression ((New-Object Net.WebClient).DownloadString("$scriptUri/$script"))
}

Invoke-Script "Utilities.ps1"

#--- Run scripts ---
Invoke-Script "WindowsUpdates.ps1"
Invoke-Script "WindowsExplorer.ps1"
