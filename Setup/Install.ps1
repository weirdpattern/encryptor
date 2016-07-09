<#
  .SYNOPSIS
    Ensures a directory exists.
  .DESCRIPTION
    Protect-Directory performs a sanity check on the $Directory path.
    The method will create the directory if it does not exist. It also returns a resolved version of the $Directory path.
  .PARAMETER $Directory
    The path to validate.
  .INPUTS
    string
  .OUTPUTS
    string
  .NOTES
    The method can be pipelined.
  .EXAMPLE
    "C:\Encryptor\Test" | Protect-Directory | Out-Null
    # Returns C:\Encryptor\Test
  .EXAMPLE
    Protect-Directory "C:/Encryptor/Test"
    # Returns C:\Encryptor\Test
    # Notice the output was resolved to a correct URI.
#>
function Protect-Directory {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Directory
    )

    Process {
        Write-Verbose "Validating Directory: $Directory"
        if (-not(Test-Path $Directory)) {

            Write-Verbose "Creating Directory: $Directory"
            New-Item -Path $Directory -ItemType Directory

        }
        return Resolve-Path $Directory
    }
}

<#
  .SYNOPSIS
    Creates Encryptor batch file.
  .DESCRIPTION
    Install-RunFile creates a new batch file that can be used to run the Encryptor module.
    The batch file name is Encryptor.cmd and will be copied to the User's desktop.
  .NOTES
    This method gets executed as part of the initial installation.
    It can be omitted, and use the PowerShell CLI to start Encryptor.
#>
function Install-RunFile {
    [CmdletBinding()]

    Param()
    Process {
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Installs run.cmd shortcut"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Does not install run.cmd shortcut"
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

        $result = $Host.ui.PromptForChoice("Would you like to create a shortcut to run Encryptor?", $message, $options, 0)
        if ($result -eq 0) {
            Write-Verbose "Creating shortcut Encryptor.cmd"
            $runCommand = Join-Path $env:USERPROFILE "Desktop/Encryptor.cmd"

            New-Item $runCommand `
                -Type File `
                -Force `
                -Value `
                "@ECHO OFF`nPowerShell -NoProfile -ExecutionPolicy Bypass -Command `"& { Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command ""Encryptor""' -Verb RunAs }`";" | Out-Null
        }
    }
}

<#
  .SYNOPSIS
    Starts Encryptor.
  .DESCRIPTION
    Invoke-Encryptor is the last step in the installation process.
    It's solely task is to run Encryptor once the module has been installed and imported.
  .PARAMETER $NoPrompt
    A switch that indicates if the user should be prompted to run Encryptor.
    Encryptor will automatically run if the switch is not used.
  .EXAMPLE
    Invoke-Encryptor
    # Will ask the user if he want's to start Encryptor
  .EXAMPLE
    Invoke-Encryptor -NoPrompt
    # Will start Encryptor without further intervention from the user.
#>
function Invoke-Encryptor {
    [CmdletBinding()]

    Param(
        [Switch]$NoPrompt
    )

    Process {
        Write-Verbose "Running Encryptor"

        if ($NoPrompt.isPresent) {
            Encryptor
        } else {
            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Runs Encryptor module"
            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Exits Encryptor installation"
            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

            $result = $Host.ui.PromptForChoice("Would you like to run Encryptor now?", $message, $options, 0)
            switch ($result) {
                0 { Encryptor }
            }
        }
    }
}

<#
  .SYNOPSIS
    Installs Encryptor.
  .DESCRIPTION
    Install-Encryptor will resolve the appropriate location to install Encryptor (based on user selections).
    Once the installation has been completedm the method calls Install-RunFile and Invoke-Encryptor.
#>
function Install-Encryptor {
    [CmdletBinding()]

    Param()
    Process {
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Installs Encryptor module for all users on this machine"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Install Encrytor module for current user"
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

        $result = $Host.ui.PromptForChoice("Would you like to make Encryptor module available for all users on this machine?", $message, $options, 0)

        $source = Split-Path -Path $PSScriptRoot -Parent
        $target = Join-Path $env:PROGRAMFILES -ChildPath "WindowsPowerShell\Modules\Encryptor"
        if ($result -eq 1) {
            $target = Join-Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Modules\Encryptor"
        }

        $target | Protect-Directory | Out-Null
        $exclude = @("Install.cmd", "Install.ps1")

        Write-Verbose "Copying Encryptor files to $target"
        Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination {
            if ($_.PSIsContainer) {
                Join-Path -Path $target -ChildPath $_.Parent.FullName.Substring($source.length) | Protect-Directory
            } else {
                Join-Path -Path $target -ChildPath $_.FullName.Substring($source.length)
            }
        } -Force -Exclude $exclude

        Install-RunFile
        Invoke-Encryptor
    }
}

<#
  .SYNOPSIS
    Loads Encryptor.
  .DESCRIPTION
    Load-Encryptor can load Encryptor without installing it first.
    Think of this method as a one-time run thing.
#>
function Load-Encryptor {
    [CmdletBinding()]

    Param()
    Process {
        Write-Verbose "Loading Encryptor module"
        Import-Module ( Split-Path -Path $PSScriptRoot -Parent | Join-Path -ChildPath "Encryptor.psd1" )

        Write-Verbose "Starting Encryptor"
        Invoke-Encryptor -NoPrompt
    }
}

if (-not( Get-Module -ListAvailable -Name Encryptor )) {

    Install-Encryptor

} else {

    Write-Host "Encryptor already installed in this host."
    Write-Host "Use Run.cmd to run it or type 'Encryptor' in a PowerShell command window."

    Invoke-Encryptor

}