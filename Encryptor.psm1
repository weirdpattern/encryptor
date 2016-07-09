<#
  .SYNOPSIS
    Start the Encryptor application.
  .DESCRIPTION
    The Start-Encryptor is the entry point to Encryptor.
    Encryptor is compose of several modules, each module has a specific task that will ultimately
    help the user to secure a dotnet application.
    Modules:
    - DotNet Configuration               : Allows the user to change environmental runtime settings.
    - Key Container Management           : Gives the user the ability to maintain key containers in the filesystem.
    - Encrypt/Decrypt Configuration File : Gives the user the ability to encrypt/decrypt configuration files in IIS
                                           websites or local filesystem.
  .NOTES
    This function can also be accessed through the following aliases:
    - Encryptor
    - Run-Encryptor
    - Open-Encryptor
    - Invoke-Encryptor
#>
function Start-Encryptor {
    [CmdletBinding()]

    Param()
    Process {
        # Import i18n resources
        Import-LocalizedData `
            -BindingVariable 'private:resources' `
            -BaseDirectory   ( Join-Path $PSScriptRoot $MyInvocation.MyCommand.Module.PrivateData.AppSettings.resxLocation ) `
            -FileName        $MyInvocation.MyCommand.Module.PrivateData.AppSettings.resxFileName

        # Keep resources as private
        $MyInvocation.MyCommand.Module.PrivateData.Resources = $private:resources
        $MyInvocation.MyCommand.Module.PrivateData.RuntimePath = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()

        # Shows the encryptor menu
        Show-EncryptorMenu
    }
}

<#
  .SYNOPSIS
    Shows the Encryptor application main menu.
  .DESCRIPTION
    The Show-EncryptorMenu displays the available options
#>
function Show-EncryptorMenu {
    [CmdletBinding()]

    Param()
    Process {
        # Renders Menu
        $option = New-Menu -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.Encryptor `
            ( New-MenuItem -Option 1 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.DotNetConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.DotNetConfigurationHelp ) `
            ( New-MenuItem -Option 2 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerManagement `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerManagementHelp ) `
            ( New-MenuItem -Option 3 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.ConfigurationFileSecurity `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.ConfigurationFileSecurityHelp ) `
            ( New-MenuItem -Option 4 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.Exit `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.ExitHelp )

        # Decides what to do next
        switch($option) {
            1 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningDotNetConfiguration
                Show-ConfigureRuntimeMenu
            }
            2 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningKeyManagement
                Show-KeyManagementMenu
            }
            3 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningConfigurationFileSecurity
                Show-ConfigurationFileSecurityMenu
            }
            4 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseExitingEncryptor
                Exit
            }
        }

        # Re-renders the menu if needed
        Show-EncryptorMenu
    }
}

<#
 Defines aliases and exports of the module.
#>
New-Alias -Name "Encryptor" `
          -Value "Start-Encryptor"

New-Alias -Name "Run-Encryptor" `
          -Value "Start-Encryptor"

New-Alias -Name "Open-Encryptor" `
          -Value "Start-Encryptor"

New-Alias -Name "Invoke-Encryptor" `
          -Value "Start-Encryptor"

Export-ModuleMember -Function Start-Encryptor `
					-Alias Encryptor, Run-Encryptor, Open-Encryptor, Invoke-Encryptor