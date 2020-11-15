# IMPORTANT: Because of the unicode box drawing characters,
# this file must be saved using "UTF-8 with BOM" encoding.

$script:indentSize = 4
$script:indent = 0

function Push-Indent {
	$script:indent += $script:indentSize
}

function Pop-Indent {
	$script:indent -= $script:indentSize
}

function Add-Indent {
	param (
		[string]$text
	)

	return $text.PadLeft($script:indent + $text.Length)
}

function Write-Header {
	param (
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

function Test-IsRunningAsAdmin {
	if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		throw "This script must be executed as an Administrator."
	}
}
