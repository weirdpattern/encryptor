<#
  .SYNOPSIS
    Creates a new menu item
  .DESCRIPTION
    New-MenuItem creates a new object with Option, Title and Description.
    The object can be later on used to create a choice in a Menu object.
  .PARAMETER $Option
    The value to be returned when this menu item is selected.
  .PARAMETER $Title
    The text of the menu item.
  .PARAMETER $Description
    A brief description of the menu item, this will be used when ? is selected.
#>
function New-MenuItem {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][int]$Option,
        [Parameter(Mandatory = $true)][string]$Title,
        [string]$Description
    )

    Process {
        return New-Object -TypeName PSObject -Prop(@{'Option' = $Option; 'Title' = $Title; 'Description' = $Description})
    }
}

<#
  .SYNOPSIS
    Creates a new menu.
  .DESCRIPTION
    New-Menu creates a menu that allows the user to navigate to different screen or execute different actions.
    The menu will cycle until a valid value has been provided, this ensures a valid option will always be returned.
  .PARAMETER $Title
    The title of the menu
  .PARAMETER $MenuItems
    The menu items to be displayed.
#>
function New-Menu {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]$MenuItems
    )

    Process {
        $maxLength = ($menuItems | Select-Object -ExpandProperty Title | Measure-Object -Property Length -Maximum).Maximum

        do {
            $validOptions = @()

            Clear-Host
            Write-Header -Title $Title

            $MenuItems | ForEach-Object {
                Write-Format -Message $( "[|{0}|] {1}" -f $_.Option, $_.Title.PadRight($maxLength, " ") ) -NoBreak
                if ($option -eq "?") {
                    Write-Format -Message $( " |- {0}|" -f $_.Description ) `
                                 -SecondaryColor Cyan `
                                 -NoBreak
                }
                $validOptions += $_.Option
                Write-Line   -NewLine
            }
            Write-Format -Message $( "[|?|] {0}" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.Help )
            Write-Line   -NewLine

            $option = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.NextAction
        } while ($option -notin $validOptions)

        return $option
    }
}