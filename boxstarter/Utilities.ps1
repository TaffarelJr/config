function Remove-WindowsStoreApp {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string] $app
    )

    process {
        Write-Host "Uninstalling $app ... " -NoNewline
        Get-AppxPackage $app -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online
        Remove-Item "$Env:LOCALAPPDATA\Packages\$app" -Recurse -Force -ErrorAction 0
        Write-Host "Done"
    }
}
