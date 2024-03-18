<#
.SYNOPSIS
    Export LitigationHold Mailboxes and get mailboxes size

.DESCRIPTION
    Export LitigationHold Mailboxes and get mailboxes size

.NOTES
    File Name      : Export_LitigationHoldMailboxes.ps1
    Author         : trisdev75
    Created        : 30/01/2024
    Last Modified  : NA
    Version        : 1.0
    PowerShell Version: 5.1
    Changelog      : 
        - Date: NA

.PARAMETER Name
    No Parameters needed

.EXAMPLE
    Add user in the inputFile
    run .\Export_LitigationHoldMailboxes.ps1
#>

# Connect Online service
Connect-ExchangeOnline

$MailboxList = # File Path
$OutputFile = # File Path

# First Export LitigationHold Enabled Mailboxes

$LitigationHoldMailboxes = Get-Mailbox -ResultSize Unlimited -Filter "LitigationHoldEnabled -eq 'True'" | Select name, Alias, userPrincipalName | Export-CSV $MailboxList

# If you have already the export 
#$LitigationHoldMailboxes = import-csv $MailboxList -Delimiter ";"

foreach($mailbox in $LitigationHoldMailboxes){
    $UPN = $mailbox.UserprincipalName
    $UPN
    $TotalSize = (Get-EXOMailboxStatistics -Identity $UPN).TotalItemSize.value
    $MailboxStatistics = Get-EXOMailboxFolderStatistics $UPN -FolderScope RecoverableItems
    $PurgeSize = ($MailboxStatistics | Where-Object {$_.Name -eq "Purges"}).FolderAndSubfolderSize
    $RecoverableSize = ($MailboxStatistics | Where-Object {$_.Name -eq "Recoverable Items"}).FolderAndSubfolderSize
    $Export = New-Object PSObject -Property @{
        UPN             = $UPN
        TotalSize       = $TotalSize
        PurgeSize       = $PurgeSize
        RecoverableSize = $RecoverableSize
    }

    $Export | Export-CSV $OutputFile -append -NoTypeInformation -Delimiter ";"

}#Foreach





