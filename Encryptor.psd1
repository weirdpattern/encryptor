@{
    RootModule = 'Encryptor.psm1'
    ModuleVersion = '1.0.0'
    GUID = ''
    Author = 'Patricio Trevino'
    PowerShellVersion = '3.0'
    FunctionsToExport = 'Start-Encryptor'
    AliasesToExport = 'Encryptor', 'Run-Encryptor', 'Open-Encryptor', 'Invoke-Encryptor'
    PrivateData = @{
        'Resources' = @{}
        'AppSettings' = @{
            'libLocation' = 'Lib'
            'resxLocation' = 'Lib\Resx'
            'resxFileName' = 'Resources.psd1'
            'defaultWebSite' = 'Default Web Site'
            'defaultApplication' = '/'
            'defaultSecurityProvider' = ''
            'defaultConfigurationSection' = 'connectionStrings'
            'cancellationToken' = 'CANCEL'
            'encryptToken' = 'encrypt'
            'decryptToken' = 'decrypt'
            'dotNetRoot' = 'C:\Windows\Microsoft.NET'
        }
        'RuntimePath' = $Null
    }
    NestedModules = @(
        '.\Lib\Components\Chooser.ps1',
        '.\Lib\Components\Menu.ps1',
        '.\Lib\Components\Printer.ps1',
        '.\Lib\Components\Summary.ps1',
        '.\Lib\Modules\ConfigureRuntime.ps1',
        '.\Lib\Modules\KeyManagement.ps1',
        '.\Lib\Modules\SecureConfiguration.ps1'
    )
    RequiredModules = @( 'WebAdministration' )
}