<#
.SYNOPSIS
    Updates Splunk Universal Forwarder (UF) hostnames to the current Windows computer name.
.DESCRIPTION
    This script updates the Splunk UF inputs.conf and server.conf files with the current windows hostname.
    If the hostname has changed since the UF was first installed, Splunk will keep using the old hostname until it is updated with this script.
.NOTES
    File Name      : Update-SplunkUFHostname.ps1
    Author         : Maximatic
    Prerequisites  : PowerShell 3.0+
    Version        : 1.0
    Date           : 2020-10-13
#>

### Declare Variables ###
    $Hostname = "$env:computername"
    $SPLUNK_HOME = "$env:ProgramFiles\SplunkUniversalForwarder"
    $ChangeCount = 0

    $InputsPath = "$SPLUNK_HOME\etc\system\local\inputs.conf"
    $InputsNewLine = "host = $Hostname"
    $InputsRegEx = 'host\s=\s.*$'

    $ServerPath = "$SPLUNK_HOME\etc\system\local\server.conf"
    $ServerNewLine = "serverName = $Hostname"
    $ServerRegEx = 'serverName\s=\s.*$'

# Update hostname in inputs.conf
    If (Test-Path -Path $InputsPath) {
        $ServerOldLine = Select-String -Path $InputsPath -Pattern $InputsRegEx | % { $_.Matches } | % { $_.Value }
        If ($InputsNewLine -ne $ServerOldLine) {
            (Get-Content -Path $InputsPath -Raw) -replace $ServerOldLine, $InputsNewLine | Set-Content -Path $InputsPath -NoNewline
            $ChangeCount++
        }
    }

# Update hostname in server.conf
    If (Test-Path -Path $ServerPath) {
        $ServerOldLine = Select-String -Path $ServerPath -Pattern $ServerRegEx | % { $_.Matches } | % { $_.Value }
        If ($ServerNewLine -ne $ServerOldLine) {
            (Get-Content -Path $ServerPath -Raw) -replace $ServerOldLine, $ServerNewLine | Set-Content -Path $ServerPath -NoNewline
            $ChangeCount++
        }
    }

# Restart SplunkForwarder service
If ($ChangeCount -gt 0) {
    If (Get-Service -Name SplunkForwarder) {
        Restart-Service -Name SplunkForwarder -Force
    }
}
