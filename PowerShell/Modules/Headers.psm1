function Start-ComponentGroup {
    <#
        .SYNOPSIS
            Writes a wide box containing the given text to the console,
            indicating that a new installation section is starting.

        .PARAMETER Text
            The text to display in the box.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Text
    )

    $outerWidth = 80
    $innerWidth = $outerWidth - 2
    $bar = '═' * $innerWidth

    $totalPadSize = $innerWidth - $Text.Length
    $lPadSize = [Math]::Floor($totalPadSize / 2)
    $rPadSize = $lPadSize + ($totalPadSize % 2)
    $lPad = ' ' * $lPadSize
    $rPad = ' ' * $rPadSize
    $color = 'Red'

    Write-Host
    Write-Host -ForegroundColor $color "╔$bar╗"
    Write-Host -ForegroundColor $color "║$lPad$Text$rPad║"
    Write-Host -ForegroundColor $color "╚$bar╝"
    Write-Host
}

#-------------------------------------------------------------------------------

function Start-Component {
    <#
        .SYNOPSIS
            Writes a small box containing the given component name to the console,
            indicating that a new component is being installed.

        .PARAMETER Name
            The name of the component to display in the box.
    #>

    param(
        [Parameter(Position = 0, Mandatory)]
        [string] $Name
    )

    $padMin = 1
    $innerWidth = $Name.Length + ($padMin * 2)
    $bar = '─' * $innerWidth

    $totalPadSize = $innerWidth - $Name.Length
    $lPadSize = [Math]::Floor($totalPadSize / 2)
    $rPadSize = $lPadSize + ($totalPadSize % 2)
    $lPad = ' ' * $lPadSize
    $rPad = ' ' * $rPadSize
    $color = 'DarkYellow'

    Write-Host
    Write-Host -ForegroundColor $color "┌$bar┐"
    Write-Host -ForegroundColor $color "│$lPad$Name$rPad│"
    Write-Host -ForegroundColor $color "└$bar┘"
    Write-Host
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Start-ComponentGroup
Export-ModuleMember -Function Start-Component
