Write-Host "Configure Windows Explorer ..."
Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"
& {
    Write-Host "    Show hidden files, folders, and drives"
    Set-ItemProperty -Path "." -Name "Hidden" -Type "DWord" -Value "1"

    Write-Host "    Show empty drives"
    Set-ItemProperty -Path "." -Name "HideDrivesWithNoMedia" -Type "DWord" -Value "0"

    Write-Host "    Show extensions for known file types"
    Set-ItemProperty -Path "." -Name "HideFileExt" -Type "DWord" -Value "0"

    Write-Host "    Show folder merge conflicts"
    Set-ItemProperty -Path "." -Name "HideMergeConflicts" -Type "DWord" -Value "0"

    Write-Host "    Restore previous folder windows at logon"
    Set-ItemProperty -Path "." -Name "PersistBrowsers" -Type "DWord" -Value "1"

    Write-Host "    Launch folder windows in a separate process"
    Set-ItemProperty -Path "." -Name "SeparateProcess" -Type "DWord" -Value "1"

    Write-Host "    Show encrypted or compressed NTFS files in color"
    Set-ItemProperty -Path "." -Name "ShowEncryptCompressedColor" -Type "DWord" -Value "1"
}
Pop-Location
