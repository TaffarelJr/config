# Load supporting script files
. "..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

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

Write-Header "Configure file extensions for Windows Search"

Write-Host "Search contents of files with extensions:"
New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null
Push-Location -Path "HKCR:\"
& {
    Push-Indent
    & {
        foreach ($extension in $indexExtensions) {
            Push-Location -Path ".\$extension\PersistentHandler\"
            & {
                Write-Host (Add-Indent $extension)
                Set-ItemProperty -Path "." -Name "(Default)" -Type "String" -Value "{5E941D80-BF96-11CD-B579-08002B30BFEB}"
                Set-ItemProperty -Path "." -Name "OriginalPersistentHandler" -Type "String" -Value "{00000000-0000-0000-0000-000000000000}"
            }
            Pop-Location
        }
    }
    Pop-Indent
}
Pop-Location
