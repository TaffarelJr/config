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

function Show-BooleanChoice {
	param (
		[string]$Caption,
		[string]$Message,
		[string]$YesHelpText,
		[string]$NoHelpText
	)

	return -NOT [boolean](Show-Choice `
		-Caption $Caption `
		-Message $Message `
		-Option1Text "&Yes" `
		-Option1HelpText $YesHelpText `
		-Option2Text "&No" `
		-Option2HelpText $NoHelpText)
}

function Show-Choice {
	param (
		[string]$Caption,
		[string]$Message,
		[string]$Option1Text,
		[string]$Option1HelpText,
		[string]$Option2Text,
		[string]$Option2HelpText
	)

	$option1 = New-Object System.Management.Automation.Host.ChoiceDescription $Option1Text, $Option1HelpText
	$option2 = New-Object System.Management.Automation.Host.ChoiceDescription $Option2Text, $Option2HelpText
	$choices = [System.Management.Automation.Host.ChoiceDescription[]]($option1, $option2)
	return $Host.UI.PromptForChoice($Caption, $Message, $choices, 0)
}

function Test-IsRunningAsAdmin {
	if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		throw "This script must be executed as an Administrator."
	}

	# Set execution policy, if necessary
	if ((Get-ExecutionPolicy) -ne "Unrestricted") {
		Set-ExecutionPolicy Bypass -Scope Process
	}

	# Use TLS 1.2
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
}
