<#
  .SYNOPSIS
    Displays the key management menu.
  .DESCRIPTION
    Show-KeyManagementMenu displays and controls the key management operations a user can perform.
    Available operations:
    - Create a new key container.
    - Remove an existing key container.
    - Import a key container configuration.
    - Export a key container configuration.
    - Grant Access to a key container.
#>
function Show-KeyManagementMenu {
    [CmdletBinding()]

    Param ()
    Process {
        # Renders Menu
        $option = New-Menu $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerManagementMenu `
            ( New-MenuItem -Option 1 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.NewKeyContainer `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.NewKeyContainerHelp ) `
            ( New-MenuItem -Option 2 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.RemoveKeyContainer `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.RemoveKeyContainerHelp ) `
            ( New-MenuItem -Option 3 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.ImportKeyContainer `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.ImportKeyContainerHelp ) `
            ( New-MenuItem -Option 4 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.ExportKeyContainer `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.ExportKeyContainerHelp ) `
            ( New-MenuItem -Option 5 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.GrantAccessKeyContainer `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.GrantAccessKeyContainerHelp ) `
            ( New-MenuItem -Option 6 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.GoBack `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.GoBackHelp )

        # Decides what to do next
        switch($option) {
            1 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningNewKeyContainerWizard
                New-KeyContainer
            }
            2 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningRemoveKeyContainerWizard
                Remove-KeyContainer
            }
            3 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningImportKeyContainerWizard
                Import-KeyContainer
            }
            4 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningExportKeyContainerWizard
                Export-KeyContainer
            }
            5 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningGrantAccessKeyContainerWizard
                Grant-AccessKeyContainer
            }
            6 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseBackToEncryptorMenu
                Return
            }
        }

        # Re-renders the menu if needed
        Show-KeyManagementMenu
    }
}

<#
  .SYNOPSIS
    Creates a new key container.
  .DESCRIPTION
    New-KeyContainer allows the user to create new key containers that can later on be used
    to encrypt/decrypt configuration files.
#>
function New-KeyContainer {
    [CmdletBinding()]

    Param ()
    Process {
        # Title
        Write-Line  -NewLine
        Write-Line  -NewLine
        Write-Title -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.NewKeyContainerTitle `
                    -Char "*" `
                    -PrimaryColor Cyan
        Write-Line  -NewLine

        # Reads the key container name to create
        $keyContainer = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerName

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Creates the key container
        Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseCalling -f ".\aspnet_regiis.exe -pc $keyContainer -exp" )
        .\aspnet_regiis.exe -pc $keyContainer -exp

        # Back to the original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red
        Read-Host
    }
}

<#
  .SYNOPSIS
    Removes an existing key container.
  .DESCRIPTION
    Remove-KeyContainer allows the user to remove existing key containers.
#>
function Remove-KeyContainer {
    [CmdletBinding()]

    Param ()
    Process {
        # Title
        Write-Line  -NewLine
        Write-Line  -NewLine
        Write-Title -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.RemoveKeyContainerTitle `
                    -Char "*" `
                    -PrimaryColor Cyan
        Write-Line  -NewLine

        # Reads the key container name to remove
        $keyContainer = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerName

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Removes the key container
        Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseCalling -f ".\aspnet_regiis.exe -pz $keyContainer" )
        .\aspnet_regiis.exe -pz $keyContainer

        # Back to the original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red
        Read-Host
    }
}

<#
  .SYNOPSIS
    Imports a key container settings.
  .DESCRIPTION
    Import-KeyContainer allows the user to import a key containers settings.
    If the key container does not exist then a new key container is created.
    If the key container exist, then it gets updated.
#>
function Import-KeyContainer {
    [CmdletBinding()]

    Param ()
    Process {
        # Title
        Write-Line  -NewLine
        Write-Title -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.ImportKeyContainerTitle `
                    -Char "*" `
                    -PrimaryColor Cyan
        Write-Line  -NewLine

        # Reads the key container name to import
        $keyContainer = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerName

        # Reads the key container xml settings location
        $keyContainerXML = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerXmlFile

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Imports the key container
        Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseCalling -f ".\aspnet_regiis.exe -pi $keyContainer $keyContainerXML" )
        .\aspnet_regiis.exe -pi $keyContainer $keyContainerXML

        # Back to the original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red
        Read-Host
    }
}

<#
  .SYNOPSIS
    Exports a key container settings.
  .DESCRIPTION
    Export-KeyContainer allows the user to export key containers settings.
    These settings can later on be imported in a different host.
#>
function Export-KeyContainer {
    [CmdletBinding()]

    Param ()
    Process {
        # Title
        Write-Line  -NewLine
        Write-Line  -NewLine
        Write-Title -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.ExportKeyContainerTitle `
                    -Char "*" `
                    -PrimaryColor Cyan
        Write-Line  -NewLine

        # Reads the key container name to export
        $keyContainer = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerName

        # Reads the drop location of the key container settings
        $keyContainerXML = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.FileDropLocation

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Exports the key container
        $filename = $( "{0}\{1}.xml" -f $keyContainerXML, $keyContainer )
        Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseCalling -f ".\aspnet_regiis.exe -px $keyContainer $filename -pri" )
        .\aspnet_regiis.exe -px $keyContainer $filename -pri

        # Back to the original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red
        Read-Host
    }
}

<#
  .SYNOPSIS
    Grants access to a key container.
  .DESCRIPTION
    Grant-AccessKeyContainer allows the user to grant access to a specific key container.
#>
function Grant-AccessKeyContainer {
    [CmdletBinding()]

    Param ()
    Process {
        # Title
        Write-Line  -NewLine
        Write-Line  -NewLine
        Write-Title -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.GrantAccessKeyContainerTitle `
                    -Char "*" `
                    -PrimaryColor Cyan
        Write-Line  -NewLine

        # Reads the key container name to update
        $keyContainer = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.KeyContainerName

        # Reads the account to add
        $account = Read-Host -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.Account

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Grants Access to the key container
        Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseCalling -f ".\aspnet_regiis.exe -pa $keyContainer $account" )
        .\aspnet_regiis.exe -pa $keyContainer $account

        # Back to the original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red
        Read-Host
    }
}