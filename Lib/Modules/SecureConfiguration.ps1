<#
  .SYNOPSIS
    Displays the configuration file security menu.
  .DESCRIPTION
    Show-ConfigurationFileSecurityMenu displays and controls the security operations a user can perform on a configuration file.
    Available operations:
    - Encrypt a configuration file hosted in an IIS Website.
    - Encrypt a configuration file located in the file system.
    - Decrypt a configuration file hosted in an IIS Website.
    - Decrypt a configuration file located in the file system.
#>
function Show-ConfigurationFileSecurityMenu {
    [CmdletBinding()]

    Param ()
    Process {
        # Renders Menu
        $option = New-Menu $MyInvocation.MyCommand.Module.PrivateData.Resources.ConfigurationFileSecurityMenu `
            ( New-MenuItem -Option 1 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.EncryptIISConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.EncryptIISConfigurationHelp   ) `
            ( New-MenuItem -Option 2 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.EncryptLocalConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.EncryptLocalConfigurationHelp ) `
            ( New-MenuItem -Option 3 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.DecryptIISConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.DecryptIISConfigurationHelp ) `
            ( New-MenuItem -Option 4 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.DecryptLocalConfiguration `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.DecryptLocalConfigurationHelp ) `
            ( New-MenuItem -Option 5 `
                           -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.GoBack `
                           -Description $MyInvocation.MyCommand.Module.PrivateData.Resources.GoBackHelp )

        # Decides what to do next
        switch($option) {
            1 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningEncryptIISConfigurationFileWizard
                Protect-IISConfiguration -Operation $MyInvocation.MyCommand.Module.PrivateData.AppSettings.encryptToken
            }
            2 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningEncryptLocalConfigurationFileWizard
                Protect-LocalConfiguration -Operation $MyInvocation.MyCommand.Module.PrivateData.AppSettings.encryptToken
            }
            3 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningDecryptIISConfigurationFileWizard
                Protect-IISConfiguration -Operation $MyInvocation.MyCommand.Module.PrivateData.AppSettings.decryptToken
            }
            4 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseOpeningDecryptLocalConfigurationFileWizard
                Protect-LocalConfiguration -Operation $MyInvocation.MyCommand.Module.PrivateData.AppSettings.decryptToken
            }
            5 {
                Write-Verbose -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.VerboseBackToEncryptorMenu
                Return
            }
        }

        # Re-renders the menu if needed
        Show-ConfigurationFileSecurityMenu
    }
}

<#
  .SYNOPSIS
    Encrypt/Decrypts a configuration file hosted in an IIS Website.
  .DESCRIPTION
    Protect-IISConfiguration does the following:
    Reads the available websites from the IIS Manager in the host machine, then allows the user to pick the website.
    Reads the applications registered in the website, then allows the user to pick the application.
    If encrypting, Reads the security providers from the application configuration file,
    then allows the user to pick the security provider.
    Prompts the user for the configuration section to encrypt/decrypt.
    Encrypts/Decrypts
  .PARAMETER $Operation
    The operation to be performed on the configuration file.
    Valid options are: encrypt | decrypt
#>
function Protect-IISConfiguration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$Operation
    )

    Process {
        # Title
        Write-Line   -NewLine
        Write-Line   -NewLine
        Write-Title  -Title $( $MyInvocation.MyCommand.Module.PrivateData.Resources.ProtectConfigurationTitle -f $Operation.ToUpper() ) `
                     -Char "*" `
                     -PrimaryColor Cyan
        Write-Line   -NewLine

        # Reads WebSite
        $website = New-Chooser `
                     -Title $MyInvocation.MyCommand.Module.PrivateData.Resources.AvailableWebsites `
                     -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectWebSite `
                     -DataSource ( Get-Website `
                         | ForEach-Object { New-ChooserItem -ID $_.Name -Description $_.Name } `
                         | Select-Object -Property ID,Description ) `
                     -DefaultValue $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultWebSite
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedWebSite -f $website )
        Write-Line   -NewLine
        Write-Line   -NewLine
        if ($website -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.cancellationToken) {
            Return
        }

        # Reads Applications
        $application = New-Chooser `
                     -Title $( $MyInvocation.MyCommand.Module.PrivateData.Resources.AvailableWebApplications -f $website ) `
                     -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectWebApplication `
                     -DataSource ( Get-WebApplication -Site $website `
                         | ForEach-Object { New-ChooserItem -ID $_.Name -Description $_.Name } `
                         | Select-Object -Property ID,Description ) `
                     -DefaultValue $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultApplication
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedWebApplication -f $application )
        Write-Line   -NewLine
        Write-Line   -NewLine
        if ($application -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.cancellationToken) {
            Return
        }

        # Reads Security Providers (encryption only)
        if ($Operation -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.encryptToken) {
            $provider = New-Chooser `
                         -Title $( $MyInvocation.MyCommand.Module.PrivateData.Resources.AvailableSecurityProviders -f $website, $application ) `
                         -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectSecurityProvider `
                         -DataSource ( Get-WebConfiguration /configProtectedData/providers/* `
                            -PSPath "IIS:\Sites\$website\$application" `
                            -Recurse | ForEach-Object { New-ChooserItem -ID $_.Name -Description $_.Name } `
                                     | Select-Object -Property ID,Description ) `
                         -DefaultValue $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultSecurityProvider
            Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedSecurityProvider -f $provider )
            Write-Line   -NewLine
            Write-Line   -NewLine
            if ($provider -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.cancellationToken) {
                Return
            }
        }

        # Reads Configuration Section
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.ConfigurationSection -f $website, $application ) `
                     -PrimaryColor Red `
                     -SecondaryColor Yellow
        $section = Read-Host -Prompt $( $MyInvocation.MyCommand.Module.PrivateData.Resources.ConfigurationSectionWithDefault -f `
                                        $Operation, $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultConfigurationSection )
        if ($section.Length -eq 0) {
            $section = $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultConfigurationSection
        }
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedConfigurationSection -f $section )
        Write-Line   -NewLine
        Write-Line   -NewLine

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Encrypts/Decrypts
        if ($Operation -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.encryptToken) {
            if ($provider.Length -gt 0) {
                Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.Calling -f `
                                          ".\aspnet_regiis.exe -pe '$section' -app '$application' -site '$website' -prov '$provider'" )
                .\aspnet_regiis.exe -pe "$section" -app "$application" -site "$website" -prov "$provider"
            } else {
                Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.Calling -f `
                                          ".\aspnet_regiis.exe -pe '$section' -app '$application' -site '$website'" )
                .\aspnet_regiis.exe -pe "$section" -app "$application" -site "$website"
            }
        } else {
            Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.Calling -f `
                                      ".\aspnet_regiis.exe -pd '$section' -app '$application' -site '$website'" )
            .\aspnet_regiis.exe -pd "$section" -app "$application" -site "$website"
        }

        # Back to original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red

        Read-Host
    }
}

<#
  .SYNOPSIS
    Encrypt/Decrypts a configuration file localed in the file system.
  .DESCRIPTION
    Protect-LocalConfiguration does the following:
    Prompts the user for the location of the configuration file.
    Reads the configuration file to extract the security providers, then allows the user to pick one.
    Prompts the user for the configuration section to encrypt/decrypt.
    Encrypts/Decrypts
  .PARAMETER $Operation
    The operation to be performed on the configuration file.
    Valid options are: encrypt | decrypt
#>
function Protect-LocalConfiguration {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true)][string]$Operation
    )

    Process {
        # Title
        Write-Line   -NewLine
        Write-Line   -NewLine
        Write-Title  -Title $( $MyInvocation.MyCommand.Module.PrivateData.Resources.ProtectConfigurationTitle -f $Operation.ToUpper() ) `
                     -Char "*" `
                     -PrimaryColor Cyan
        Write-Line   -NewLine

        # Reads Configuration File Location
        Write-Format -Message $MyInvocation.MyCommand.Module.PrivateData.Resources.LocationConfigurationFile `
                     -PrimaryColor Red `
                     -SecondaryColor Yellow

        # And keeps doing it until the path is valid
        do {
            $path = Read-Host -Prompt $( $MyInvocation.MyCommand.Module.PrivateData.Resources.LocalPathConfigurationFile -f $Operation )
        } while (($path.Length -eq 0) -or (-not(Test-Path $path)))

        # Path sanitization
        $path = Resolve-Path $path
        $configPath = Join-Path -Path $path -ChildPath "web.config"

        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedLocalPathConfigurationFile -f $path )
        Write-Line   -NewLine
        Write-Line   -NewLine

        # Reads Security Providers (encryption only)
        if ($Operation -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.encryptToken) {
            $provider = New-Chooser `
                         -Title $( $MyInvocation.MyCommand.Module.PrivateData.Resources.LocalAvailableSecurityProviders -f $configPath ) `
                         -Prompt $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectSecurityProvider `
                         -DataSource ( Get-SecurityProviders -Path $path `
                             | ForEach-Object { New-ChooserItem -ID $_.Name -Description $_.Name } `
                             | Select-Object -Property ID,Description ) `
                         -DefaultValue $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultSecurityProvider
            Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedSecurityProvider -f $provider )
            Write-Line   -NewLine
            Write-Line   -NewLine
            if ($provider -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.cancellationToken) {
                Return
            }
        }

        # Reads Configuration Section
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.LocalConfigurationSection -f $configPath ) `
                     -PrimaryColor Red `
                     -SecondaryColor Yellow
        $section = Read-Host -Prompt $( $MyInvocation.MyCommand.Module.PrivateData.Resources.ConfigurationSectionWithDefault -f `
                                        $Operation, $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultConfigurationSection )
        if ($section.Length -eq 0) {
            $section = $MyInvocation.MyCommand.Module.PrivateData.AppSettings.defaultConfigurationSection
        }
        Write-Format -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.SelectedConfigurationSection -f $section )
        Write-Line   -NewLine
        Write-Line   -NewLine

        # Change the location context to $Runtime
        $currentLocation = Get-Location
        Set-Location -Path $MyInvocation.MyCommand.Module.PrivateData.RuntimePath

        # Encrypts/Decrypts
        if ($Operation -eq $MyInvocation.MyCommand.Module.PrivateData.AppSettings.encryptToken) {
            if ($provider.Length -gt 0) {
                Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.Calling -f `
                                          ".\aspnet_regiis.exe -pef '$section' '$path' -prov '$provider'" )
                .\aspnet_regiis.exe -pef "$section" "$path" -prov "$provider"
            } else {
                Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.Calling -f `
                                          ".\aspnet_regiis.exe -pef '$section' '$path'" )
                .\aspnet_regiis.exe -pef "$section" "$path"
            }
        } else {
            Write-Verbose -Message $( $MyInvocation.MyCommand.Module.PrivateData.Resources.Calling -f `
                                      ".\aspnet_regiis.exe -pdf '$section' '$path'" )
            .\aspnet_regiis.exe -pdf "$section" "$path"
        }

        # Back to original location context
        Set-Location -Path $currentLocation

        Write-Line   -NewLine
        Write-Format -Message $( "[{0}]" -f $MyInvocation.MyCommand.Module.PrivateData.Resources.EnterToContinue ) `
                     -PrimaryColor Red

        Read-Host
    }
}

<#
  .SYNOPSIS
    Reads the web.config file located in $Path and gets the available security providers.
  .PARAMETER $Path
    The .NET runtime to be used to encrypt/decrypt a configuration file.
  .INPUTS
    string
  .OUTPUTS
    List of Security Provider Objects
  .EXAMPLE
    Get-SecurityProviders "C:\Encryptor\Test"
    # Reads C:\Encryptor\Test\web.config
    # Outputs { Name, Type, KeyContainerName, UseMachineContainer }
#>
function Get-SecurityProviders {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    Process {
        $config = [Xml] ( Get-Content $( Join-Path -Path $Path -ChildPath "web.config" ) )
        return $config.configuration.configProtectedData.providers.add
    }
}
