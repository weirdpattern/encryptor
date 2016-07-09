<#
  .SYNOPSIS
    Displays the .Net configuration menu.
  .DESCRIPTION
    Show-ConfigureRuntimeMenu displays and controls the .Net configuration operations a user can perform.
    Available operations:
    - View the current runtime information.
    - Update the runtime information.
  .PARAMETER $Runtime
    The .NET runtime to be used to manage the key containers and configuration file security.
  .INPUTS
    string
#>
function Show-ConfigureRuntimeMenu {
    [CmdletBinding()]

    Param()
    Process {
        # Renders Menu
        $option = New-Menu $MyInvocation.MyCommand.Module.PrivateData.Resources.DotNetConfigurationMenu `
            ( New-MenuItem -Option 1 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.CurrentConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.CurrentConfigurationHelp ) `
            ( New-MenuItem -Option 2 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.UpdateConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.UpdateConfigurationHelp ) `
            ( New-MenuItem -Option 3 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.GoBack `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.GoBackHelp )

        # Decides what to do next
        switch($option) {
            1 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseDisplayingRuntimeInformation
                New-Summary -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.CurrentConfigurationTitle ( `
                    New-SummaryItem -Label $MyInvocation.MyCommand.Module.PrivateData.Resources.RuntimePath `
                                    -Description $MyInvocation.MyCommand.Module.PrivateData.RuntimePath `
                )
            }
            2 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningUpdateRuntimePathWizard
                Update-RuntimePath
            }
            3 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseBackToEncryptorMenu
                Return
            }
        }

        # Re-renders the menu if needed
        Show-ConfigureRuntimeMenu
    }
}

<#
  .SYNOPSIS
    Reads the new the current runtime path.
  .DESCRIPTION
    Update-RuntimePath presents the user with a list of available runtimes (out
  .EXAMPLE
    Get-CurrentRuntimePath
    # Returns C:\Windows\Microsoft.NET\Framework64\v4.0.30319

    New-CurrentRuntimePath
    # User inputs -> "C:\Encryptor\Test"

    Get-CurrentRuntimePath
    # Returns C:\Encryptor\Test
#>
function Update-RuntimePath {
    [CmdletBinding()]

    Param()
    Process {
        Write-Line   -NewLine
        Write-Format -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.SearchingForRuntimes
        Write-Line   -NewLine

        # Gets the available folders
        $runtimes = Get-ChildItem -Path $MyInvocation.MyCommand.Module.PrivateData.AppSettings.DotNetRoot -Recurse `
                        | Where { ($_.PSIsContainer) -and (Join-Path -Path $_.FullName -ChildPath "aspnet_regiis.exe" | Test-Path) } `
                        | ForEach-Object { New-ChooserItem -ID $_.FullName -Description $_.FullName } `
                        | Select-Object -Property ID,Description

        # Selects the new runtime
        $runtime = New-Chooser `
                     -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.AvailableRuntimes `
                     -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectRuntime `
                     -DataSource $runtimes `
                     -DefaultValue $MyInvocation.MyCommand.Module.PrivateData.RuntimePath
        if ($runtime -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.cancellationToken) {
            Return
        }

        # Reads the current runtime configuration
        $oldRuntime = $MyInvocation.MyCommand.Module.PrivateData.RuntimePath
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.RuntimeChangedConfiguration -f $oldRuntime, $runtime )

        # Sets the new runtime configuration
        $MyInvocation.MyCommand.Module.PrivateData.RuntimePath = $runtime

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Cyan
        Read-Host
        #>
    }
}