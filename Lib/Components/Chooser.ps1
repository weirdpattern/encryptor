<#
  .SYNOPSIS
    Creates a new choice item
  .DESCRIPTION
    New-ChooserItem creates a new object with ID and Description.
    The object can be later on used to create a choice in a Chooser object.
  .PARAMETER $ID
    The id of the choice.
  .PARAMETER $Description
    The description of the choice.
#>
function New-ChooserItem {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$ID,
        [Parameter(Mandatory = $true)][string]$Description
    )

    Process {
        return New-Object -TypeName PSObject -Prop(@{'ID' = $ID; 'Description' = $Description})
    }
}

<#
  .SYNOPSIS
    Creates a new chooser menu.
  .DESCRIPTION
    New-Chooser creates a menu that display multiple choices.
    This controls allows the user to select the choice he/she wants to use to complete an action.
    A menu with only one choice will preselect the sole value and return it.
  .PARAMETER $Title
    The title of the chooser menu
  .PARAMETER $Prompt
    The message of the chooser, this allows the user to identify the origin of the choices.
  .PARAMETER $DataSource
    The choices to be displayed. Optional value
  .PARAMETER $DefaultValue
    The default value to return if no choices are provided.
#>
function New-Chooser {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Prompt,
        [Object[]]$DataSource,
        [string]$DefaultValue
    )

    Process {

        Write-Format -Message $Title `
                     -PrimaryColor Red `
                     -SecondaryColor Yellow
        Write-Line   -NewLine

        if (($DataSource -eq $null) -or ($DataSource.Count -eq 0)) {
            Write-Format -Message $( "  [|1|] {0} ({1})" -f $DefaultValue, $MyInvocation.MyCommand.Module.PrivateData.Resources.Preselected )
            Write-Line -NewLine
            Write-Format -Message $( $Prompt + ": " + $DefaultValue )
            return $DefaultValue
        }

        if ($DataSource.Count -gt 1) {
            $index = 1
            $validOptions = @{}

            $DataSource | ForEach-Object {
                Write-Format -Message $( "  [|{0}|] {1}" -f $index, $_.Description )
                $validOptions.add($index.ToString(), $_.ID)
                $index = $index + 1
            }

            $cancellingIndex = $index
            Write-Format -Message $( "  [|{0}|] {1}" -f $index, $MyInvocation.MyCommand.Module.PrivateData.Resources.Cancel )
            $validOptions.add($index.ToString(), $MyInvocation.MyCommand.Module.PrivateData.AppSettings.cancellationToken)

            Write-Line -NewLine
            $found = $true;
            do {

                $option = Read-Host -Prompt $Prompt
                $found = $validOptions.ContainsKey($option.ToString())
                if (-not($found)) {
                    Write-Warning -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.InvalidOption -f $option )
                }

            } while (-not($found))

            return $validOptions.Get_Item($option)
        }

        Write-Format -Message $( "  [|1|] {0} ({1})" -f $DataSource[0].Description, $MyInvocation.MyCommand.Module.PrivateData.Resources.Preselected )
        Write-Line -NewLine
        Write-Format -Message $( "{0}: 1" -f $Prompt )
        return $DataSource[0].ID
    }
}