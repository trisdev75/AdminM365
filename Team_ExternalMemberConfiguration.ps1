<#
.SYNOPSIS
    Team configuration for external members

.DESCRIPTION
    If you add external member to the team, you want they receive email/calendar event, etc.. in external mailbox
    External user can send email to Team.
    You want to show the Team in Outlook.

.NOTES
    File Name      : Team_ExternalMemberConfiguration.ps1
    Author         : trisdev75
    Created        : 18/03/2024
    Last Modified  : NA
    Version        : 1.0
    PowerShell Version: 5.1
    Changelog      : 
        - Date: NA

.PARAMETER Name
    No Parameters needed

.EXAMPLE
    .\Team_ExternalMemberConfiguration.ps1
    Configure the Teams in the inputFile
#>


# Define Functions
#  Write-Log
function Write-Log{

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('OK','ERROR','Warning')]
        [String]$Etat

    )
    [pscustomobject]@{
        Heure = (Get-Date -f g)
        Message = $Message
        Etat = $Etat
    } | Export-CSV $LogFile -Append -NoTypeInformation -Delimiter "," -Encoding Default
}

# Files
$InputFile = #FILE TO IMPORT
$OutputFile = #PATH TO OUTPUT
$LogFile = #PATH TO LOG FILE

# CSV
#TeamName;

$Teams = import-CSV $InputFile


Connect-ExchangeOnline

#Send copies of email to external member
#Show Team in Outlook
#Allow external user to send message/


foreach($Team in $Teams){
    $TeamName = $Team.TeamName
    try{
        Set-UnifiedGroup -Identity $TeamName -AutoSubscribeNewMembers -HiddenFromExchangeClientsEnabled:$false -AcceptMessagesOnlyFromSendersOrMembers:$false
        Write-Log -Message "Set Configuration for $TeamName" -Status OK
    }
    catch{
        Write-Log -Message "Set Configuration for $TeamName" -Status Error
    }

}# Foreach

