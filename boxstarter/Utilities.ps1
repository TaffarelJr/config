New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null

function Write-Header {
	Param (
		[string]$text
	)

	$color = "Yellow"
	$line = "─" * ($text.Length + 2)

	Write-Host
	Write-Host "┌$($line)┐" -ForegroundColor $color
	Write-Host "│ $($text) │" -ForegroundColor $color
	Write-Host "└$($line)┘" -ForegroundColor $color
	Write-Host
}

function Remove-WindowsStoreApp {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$app
    )

    process {
        Write-Host "Uninstalling $app ... " -NoNewline
        Get-AppxPackage $app -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online
        Remove-Item "$Env:LOCALAPPDATA\Packages\$app" -Recurse -Force -ErrorAction 0
        Write-Host "Done"
    }
}
