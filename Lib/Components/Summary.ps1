<#
  .SYNOPSIS
    Creates a new summary item
  .DESCRIPTION
    New-SummaryItem creates a new object with Label  and Description.
  .PARAMETER $Label
    The text of the summary item.
  .PARAMETER $Description
    A brief description of the summary item.
#>
function New-SummaryItem {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Description
    )

    Process {
        return New-Object -TypeName PSObject -Prop(@{'Label'=$Label; 'Description'=$Description})
    }
}

<#
  .SYNOPSIS
    Creates a new summary.
  .DESCRIPTION
    New-Summary creates a list-like display with results.
    This control is merely informative.
  .PARAMETER $Title
    The title of the summary
  .PARAMETER $Results
    The results to be displayed.
#>
function New-Summary {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]$Results
    )

    Process {
        Write-Line   -NewLine
        Write-Line   -NewLine

        Write-Title  -Title $Title `
                     -Char "*" `
                     -PrimaryColor Cyan
        Write-Line   -NewLine

        $Results | ForEach-Object { Write-Format -Message $( "{0} : |{1}|" -f $_.Label, $_.Description ) }
        Write-Line   -NewLine

        Write-Line   -Char "*" `
                     -Length 80 `
                     -PrimaryColor Cyan `
                     -NewLine
        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red
        Read-Host
    }
}