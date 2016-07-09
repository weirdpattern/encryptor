<#
  .SYNOPSIS
    Writes a message to the standard output applying color formatting to it.
  .DESCRIPTION
    Write-Format will format the message prior to send it to the standard output (Write-Host).
    The message can be formatted with a primary foreground color, a secondary foreground color and
    a background color.
    The secondary color gets applied to anything between |.
  .PARAMETER $Message
    The message to be formatted.
  .PARAMETER $PrimaryColor
    The primary color to be used. This is optional and defaults to White.
  .PARAMETER $SecondaryColor
    The secondary color to be used. This is optional and defaults to Yellow.
  .PARAMETER $BackgroundColor
    The background color to be used. This is optional and defaults to the Host background color.
  .PARAMETER $NoBreak
    A switch that can be used to keep the cursor on the same line.
#>
function Write-Format {
    [CmdletBinding()]

    Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [AllowEmptyString()]
        [String]       $Message,
        [ConsoleColor] $PrimaryColor    = [ConsoleColor]::White,
        [ConsoleColor] $SecondaryColor  = [ConsoleColor]::Yellow,
        [ConsoleColor] $BackgroundColor = $Host.UI.RawUI.BackgroundColor,
        [Switch]       $NoBreak
    )

    Process {
        $tickPosition = $Message.IndexOf("|");
        if ($tickPosition -eq -1) {
            Write-Host $Message `
                -Foreground $PrimaryColor `
                -Background $BackgroundColor `
                -NoNewLine
        } else {
            $startIndex = 0;
            while ($tickPosition -gt -1) {
                Write-Host $Message.Substring($startIndex, $tickPosition - $startIndex) `
                    -Foreground $PrimaryColor `
                    -Background $BackgroundColor `
                    -NoNewLine

                $startIndex   = $tickPosition + 1
                $tickPosition = $Message.IndexOf("|", $startIndex)

                Write-Host $Message.Substring($startIndex, $tickPosition - $startIndex) `
                    -Foreground $SecondaryColor `
                    -Background $BackgroundColor `
                    -NoNewLine

                $startIndex   = $tickPosition + 1
                $tickPosition = $Message.IndexOf("|", $startIndex)

                if($tickPosition -eq -1) {
                    Write-Host $Message.Substring($startIndex) `
                        -Foreground $PrimaryColor `
                        -Background $BackgroundColor `
                        -NoNewLine
                }
            }
        }
    }
    End {
        if (-not($NoBreak.IsPresent)) { Write-Host }
    }
}

<#
  .SYNOPSIS
    Writes a line of characters.
  .DESCRIPTION
    Write-Line can be used to output a line of characters.
  .PARAMETER $Char
    The char to be used to fill the line. This is optional and defaults to whitespace.
  .PARAMETER $Length
    The length of the line. This is optional and defaults to 0.
    If default is used, then nothing gets send to the output.
  .PARAMETER $PrimaryColor
    The primary color to be used. This is optional and defaults to White.
  .PARAMETER $SecondaryColor
    The secondary color to be used. This is optional and defaults to Yellow.
  .PARAMETER $BackgroundColor
    The background color to be used. This is optional and defaults to the Host background color.
  .PARAMETER $NewLine
    A switch that can be used to add a break at the end of the line.
  .EXAMPLE
    Write-Line -NewLine
    # Writes
    # (empty line)
  .EXAMPLE
    Write-Line "*" 80
    # Writes
    # ************************************************************************
  .EXAMPLE
    Write-Line "*" 80 Red
    # Writes
    # ************************************************************************
    # in Red color
#>
function Write-Line {
    [CmdletBinding()]

    Param(
        [String]       $Char            = " ",
        [Int]          $Length          = 0,
        [ConsoleColor] $PrimaryColor    = [ConsoleColor]::White,
        [ConsoleColor] $SecondaryColor  = [ConsoleColor]::Yellow,
        [ConsoleColor] $BackgroundColor = $host.UI.RawUI.BackgroundColor,
        [Switch]       $NewLine
    )

    Process {
        1..$Length | ForEach-Object {
            Write-Format -Message $Char `
                         -PrimaryColor $PrimaryColor `
                         -SecondaryColor $SecondaryColor `
                         -NoBreak
        }

        if ($NewLine.IsPresent) { Write-Host }
    }
}

<#
  .SYNOPSIS
    Writes a header.
  .DESCRIPTION
    Write-Header will write a header.
    The header will be enclosed between two lines of *****.
  .PARAMETER $Title
    The title of the header.
  .PARAMETER $PrimaryColor
    The primary color to be used. This is optional and defaults to White.
  .PARAMETER $SecondaryColor
    The secondary color to be used. This is optional and defaults to Yellow.
  .PARAMETER $BackgroundColor
    The background color to be used. This is optional and defaults to the Host background color.
  .EXAMPLE
    Write-Header "HEADER"
    # Writes
    # ************************************************************************
    #                                HEADER
    # ************************************************************************
#>
function Write-Header {
    [CmdletBinding()]

    Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]       $Title,
        [ConsoleColor] $PrimaryColor    = [ConsoleColor]::White,
        [ConsoleColor] $SecondaryColor  = [ConsoleColor]::Yellow,
        [ConsoleColor] $BackgroundColor = $host.UI.RawUI.BackgroundColor
    )

    Process {
        Write-Line   -NewLine
        Write-Line   -Char "*" `
                     -Length 80 `
                     -PrimaryColor $PrimaryColor `
                     -SecondaryColor $SecondaryColor `
                     -BackgroundColor $BackgroundColor `
                     -NewLine
        Write-Line   -Length (40 - [Math]::Ceiling($Title.Length / 2) - 1) `
                     -PrimaryColor $PrimaryColor `
                     -SecondaryColor $SecondaryColor `
                     -BackgroundColor $BackgroundColor
        Write-Format -Message $Title `
                     -PrimaryColor $PrimaryColor `
                     -SecondaryColor $SecondaryColor `
                     -BackgroundColor $BackgroundColor
        Write-Line   -Char "*" `
                     -Length 80 `
                     -PrimaryColor $PrimaryColor `
                     -SecondaryColor $SecondaryColor `
                     -BackgroundColor $BackgroundColor `
                     -NewLine
        Write-Line   -NewLine
    }
}

<#
  .SYNOPSIS
    Writes a title.
  .DESCRIPTION
    Write-Title will write a title striked by a line of $Char.
  .PARAMETER $Title
    The title of the header.
  .PARAMETER $Char
    The char to be used to fill the border of the title.
  .PARAMETER $PrimaryColor
    The primary color to be used. This is optional and defaults to White.
  .PARAMETER $SecondaryColor
    The secondary color to be used. This is optional and defaults to Yellow.
  .PARAMETER $BackgroundColor
    The background color to be used. This is optional and defaults to the Host background color.
  .EXAMPLE
    Write-Title "HEADER"
    # Writes
    # ****************************** HEADER **********************************
#>
function Write-Title {
    [CmdletBinding()]

    Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]       $Title,
        [string]       $Char            = "*",
        [ConsoleColor] $PrimaryColor    = [ConsoleColor]::White,
        [ConsoleColor] $SecondaryColor  = [ConsoleColor]::Yellow,
        [ConsoleColor] $BackgroundColor = $host.UI.RawUI.BackgroundColor
    )

    Process {
        Write-Line   -Char $Char `
                     -Length (40 - [Math]::Ceiling($Title.Length / 2) - 2) `
                     -PrimaryColor $PrimaryColor `
                     -SecondaryColor $SecondaryColor `
                     -BackgroundColor $BackgroundColor
        Write-Format -Message $( " {0} " -f $Title ) `
                     -PrimaryColor $PrimaryColor `
                     -SecondaryColor $SecondaryColor `
                     -BackgroundColor $BackgroundColor `
                     -NoBreak

        $pad = 0
        if ($Title.Length % 2 -ne 0) {
            $pad = 1
        }

        Write-Line -Char $Char `
                   -Length (40 - [Math]::Ceiling($Title.Length / 2) + $pad) `
                   -PrimaryColor $PrimaryColor `
                   -SecondaryColor $SecondaryColor `
                   -BackgroundColor $BackgroundColor `
                   -NewLine
    }
}