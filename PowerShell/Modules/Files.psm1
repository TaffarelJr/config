using namespace System.Text.RegularExpressions

#-------------------------------------------------------------------------------

function Assert-File {
    <#
        .SYNOPSIS
            Ensures a file exists.

        .PARAMETER Path
            The path to the file.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Host "Creating file '$Path'"
        New-Item -Path $Path -ItemType File | Out-Null
    }
}

#-------------------------------------------------------------------------------

function Assert-FileContentBlock {
    <#
        .SYNOPSIS
            Ensures the given content block exists in the specified file.

        .PARAMETER Path
            The path to the file.

        .PARAMETER Find
            A RegularExpression representing the content to search for in the file.
            The first match is replaced by the given content.
            If no match is found, the content is appended to the end of the file.

        .PARAMETER Content
            The content to be added to the file.
            If it already exists in the file (matching the Find parameter above),
            then it's replaced with this new value.
            Otherwise, it's appended to the end of the file.

        .PARAMETER LineEnding
            The line ending to use when appending content.
            Optional. Defaults to CRLF.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Path,

        [Parameter(Position = 1, Mandatory)]
        [string] $Find,

        [Parameter(Position = 2, Mandatory)]
        [string] $Content,

        [Parameter(Position = 3)]
        [string] $LineEnding = "`r`n"
    )

    # Ensure proper line endings in new content
    $Content = Assert-LineEndings -Text $Content -LineEnding $LineEnding

    # Load the contents of the file
    Assert-File -Path $Path
    $existingContent = Get-Content -Path $Path -Raw
    if ($existingContent) {
        $existingContent = $existingContent.Trim()
    }

    if (($null -eq $existingContent) -or ($existingContent.Length -eq 0)) {
        # If the file is empty, just write the given content to the file
        Write-Host "Appending content to (empty) '$Path'"
        Set-Content -Path $Path -Value $Content
    }
    else {
        # Define a delegate that will perform replacement, if necessary
        $matchEvaluator = {
            param ($match)

            # Get any text preceeding the existing content, and add padding
            $pre = $match.Groups["pre"].Value.TrimEnd()
            if ($pre.Length -gt 0) {
                $pre += ($LineEnding * 2)
            }

            # Get any text succeeded the existing content, and add padding
            $post = $match.Groups["post"].Value.TrimStart()
            if ($post.Length -gt 0) {
                $post = ($LineEnding * 2) + $post
            }

            # Combine the blocks and return the result
            Set-Variable -Name 'contentReplaced' -Value $true -Scope 1
            return "$pre$Content$post"
        }

        # Attempt to replace any existing content
        $contentReplaced = $false
        $newContent = [Regex]::Replace(
            $existingContent,
            "^(?<pre>.*?)$Find(?<post>.*?)$",
            $matchEvaluator,
            [RegexOptions]::ExplicitCapture -bor [RegexOptions]::Singleline
        )

        if ($contentReplaced) {
            if ($newContent -cne $existingContent) {
                # If the content was actually updated, replace the file contents
                Write-Host "Replacing old content in '$Path'"
                Set-Content -Path $Path -Value $newContent
            }
        }
        else {
            # If the content wasn't found, just append it to the end of the file
            Write-Host "Appending content to '$Path'"
            Set-Content -Path $Path -Value "$existingContent$($LineEnding * 2)$Content"
        }
    }
}

#-------------------------------------------------------------------------------

function Assert-LineEndings {
    <#
        .SYNOPSIS
            Ensures the specified text has the specified line endings.

        .PARAMETER Text
            The text to be inspected.

        .PARAMETER LineEnding
            The line ending to use when appending content.
            Optional. Defaults to CRLF.

        .OUTPUTS
            The given text with the specified line endings.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Text,

        [Parameter(Position = 1)]
        [string] $LineEnding = "`r`n"
    )

    # Ensure proper line endings in given text
    switch ($LineEnding) {
        "`r`n" {
            return [Regex]::Replace($Text, '([^\r])\n', '$1\r\n', [RegexOptions]::Singleline)
        }

        "`n" {
            return $Text.Replace("`r`n", "`n")
        }
    }
}

#-------------------------------------------------------------------------------

function Remove-File {
    <#
        .SYNOPSIS
            Ensures a file does not exist.

        .PARAMETER Path
            The path to the file.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Path
    )

    if (Test-Path -Path $Path) {
        Write-Host "Deleting file '$Path'"
        Remove-Item -Path $Path
    }
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Assert-File
Export-ModuleMember -Function Assert-FileContentBlock
Export-ModuleMember -Function Assert-LineEndings
Export-ModuleMember -Function Remove-File
