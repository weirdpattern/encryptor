0.0.1 / 2015-07-25
==================

  * Initial commit

0.0.2 / 2015-07-25
==================

  * Code formatting (tabs to spaces)
  * Update to .gitignore

0.1.0 / 2015-07-27
==================

  * Encryptor.psd1
    - Version change
    - Reorder aliases

  * Encryptor.psm1
    - Added comments

  * Run.cmd renamed to Install.cmd

  * Configuration/AppSettings.ps1
    - Added comments

  * Configuration/ExportSettings.ps1
    - Added comments

  * Register.ps1 renamed to Install.ps1 and moved from Configuration/ to Setup/

  * Encryptor.ps1
    - Updated comments
    - Better switch handling

  * Components/Chooser.ps1
    - Formatting
    - Fix message formatting on 1 item choosers.

  * Components/Menu.ps1
    - Formatting

  * Components/Printer.ps1
    - Formatting

  * Components/Summary.ps1
    - Formatting

  * Modules/ConfigureRuntime.ps1
    - Added comments
    - Better switch handling
    - Removed `Get-CurrentRuntimePath`
    - Removed `Set-CurrentRuntimePath`
    - Renamed `Updated-CurrentRuntimePath` to `New-CurrentRuntimePath`
    - $runtimePath is now a script level variable
    - Formatting

  * Modules/KeyManagement.ps1
    - Added comments
    - Better switch handling
    - Formatting

  * Modules/SecureConfiguration.ps1
    - Added comments
    - Better switch handling
    - Formatting
    - `Protect-LocalConfiguration` now reads the selected config file and extracts the security providers.
    - Added method `Get-SecurityProviders` to extract the security providers.

  * Resx/en-US/Resources.ps1
    - Updates to resources

1.0.0.rc / 2015-07-28
=====================

  * Removed Configuration/*

  * Encryptor.psd1
    - Include PrivateData to maintain state of the module.
    - Format NestedModules.

  * Encryptor.psm1
    - Moved `Start-Encryptor` from Lib/Encryptor.ps1, this method also loads the resources
      and initializes the PrivateData of the module.
    - Added `Show-EncryptorMenu`.

  * Setup/Install.ps1
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.

  * Lib/Components/Chooser.ps1
    - Added documentation.
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.
    - Modified code to use PrivateData instead of resources and appsettings.

  * Lib/Components/Menu.ps1
    - Added documentation.
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.
    - Modified code to use PrivateData instead of resources and appsettings.

  * Lib/Components/Printer.ps1
    - Added documentation.
    - Convert functions to cmdlets.

  * Lib/Components/Summary.ps1
    - Added documentation.
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.
    - Modified code to use PrivateData instead of resources and appsettings.

  * Lib/Modules/ConfigureRuntime.ps1
    - Renamed `New-CurrentRuntimePath` to `Update-RuntimePath`, the method now reads
      the availabel .NET paths in C:\Windows\Microsoft.NET\ folder and displays the
      options to the user so he/she can pick from that list.
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.
    - Modified code to use PrivateData instead of resources and appsettings.

  * Lib/Modules/KeyManagement.ps1
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.
    - Modified code to use PrivateData instead of resources and appsettings.

  * Lib/Modules/SecureConfiguration.ps1
    - Convert functions to cmdlets.
    - Added Write-Verbose statements.
    - Modified code to use PrivateData instead of resources and appsettings.

 1.0.0 / 2015-07-29
===================

  * Updated README.md

  * Encryptor.psd1
    - Updated version.

  * Setup/Install.ps1
    - Updated installation messages.