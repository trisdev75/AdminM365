<#
.SYNOPSIS
    Export Mailboxsize for a user's list.

.DESCRIPTION
    User a CSV file containing userPrincipalName of users.

.NOTES
    File Name      : Export1_MailboxeSize.ps1
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
    .\Export_MailboxSize.ps1
    Create an output file with mailboxsize.
#>


# Main script execution

# Connect To ExchangeOnline
Connect-ExchangeOnline

# Files
$FilePath = #FILE TO IMPORT
$OutputFile = #PATH TO OUTPUT

# CSV
#userPrincipalName;

$Users = import-CSV $FilePath
$Result = New-Object System.Collections.ArrayList

foreach($user in $Users){
    $UPN = $user.UPN
    $Size = (Get-EXOMailboxStatistics -Identity $UPN).TotalItemSize
    $MailboxSize = [PSCustomObject]@{
            UPN = $UPN
            TotalItemSize = $Size
        }
    $Null = $Result.Add($MailboxSize)

}#For each

$Result | Export-csv $OutputFile -Delimiter ";" -NoTypeInformation -Append

# Disconnect
Disconnect-ExchangeOnline
