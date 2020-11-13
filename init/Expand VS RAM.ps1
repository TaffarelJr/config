ForEach ($version in 11,12,14,15,16) {
    $vs = [System.IO.Path]::GetFullPath([System.Environment]::ExpandEnvironmentVariables("%VS$($version)0COMNTOOLS%..\.."))
    $editbin = "$vs\VC\bin\editbin.exe"
    $devenv  = "$vs\Common7\IDE\devenv.exe"
    
    Write-Host
    Write-Host "Checking for Visual Studio $version ..."
    Write-Host "Checking path $vs"
    
    If ((Test-Path "$editbin") -and (Test-Path "$devenv")) {
        Write-Host "Found. Configuring to use more RAM ..."
        & "$editbin" /LARGEADDRESSAWARE "$devenv"
        
    } Else {
        Write-Host "Not found."
    }
}