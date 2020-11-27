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
