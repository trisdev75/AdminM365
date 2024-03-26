<#
.SYNOPSIS
    Get all quarantined Email from specific domain to specific domains

.DESCRIPTION
    Add specific domain in $DomainSenders, and one line per Recipient domain.
    You can custom the StartDate.
    The script will get the quarantined message, and get the SPF/DKIM/DMARC result.

.NOTES
    File Name      : Get-QuarantinedMessages.ps1
    Author         : DEVILLES Tristan
    Created        : 26/03/2023
    Last Modified  : NA
    Version        : 1.0
    PowerShell Version: 5.1
    Changelog      : 
        - Date: NA

.PARAMETER Name
    No Parameters needed
#>

# Main script starts here 

# Connect To Online Service

Connect-ExchangeOnline


# init date
$Today = Get-Date
$Yesterday = ($Today).AddDays(-1)


# Outfile
$YesterdayOutput = ($Today).AddDays(-1).ToString('dd-MM-yyyy')
$Outfile = #Path to output file


# List of Domain Senders
$DomainSenders = (
"*@domain.com",
"*@domain.com"
)

# Init Tab
$TabResults = @()
$FinalResults =@()

# Get All the quarantine Messages with criteria
foreach($DomainSender in $DomainSenders)
{
    $DomainSender
    $QuarantineResults = Get-QuarantineMessage -SenderAddress $DomainSender -RecipientAddress "*@RecipientDomain" -StartReceivedDate $Yesterday -EndReceivedDate $Today | Select ReceivedTime,SenderAddress,RecipientAddress,Type, MessageId, Identity
    $TabResults +=$QuarantineResults
    $QuarantineResults = Get-QuarantineMessage -SenderAddress $DomainSender -RecipientAddress "*@RecipientDomain" -StartReceivedDate $Yesterday -EndReceivedDate $Today | Select ReceivedTime,SenderAddress,RecipientAddress,Type, MessageId, Identity
    $TabResults+=$QuarantineResults
  
}# Foreach

# Analyse each header from Quarantine Messages
foreach($Result in $TabResults)
{
    $ReceivedTime = $Result.ReceivedTime
    $SenderAddress = $Result.SenderAddress
    $RecipientAddress = $Result.RecipientAddress
    $Type = $Result.Type
    $MessageId = $Result.MessageId
    $Identity = $Result.Identity
    
    $quarantineMessage = Get-QuarantineMessageHeader -identity $Result.Identity
    $quarantineMessageHeader = $quarantineMessage.header

    # Regex to find SPF/DKIM/DMARC/CompAuth/Precedence
    $spfPattern = "SPF=([\w-]+)"
    $dkimPattern = "dkim=([\w-]+)"
    $DmarcPattern = "dmarc=([\w-]+)"
    $CompAuthPattern = "compauth=([\w-]+)"
    $PrecedencePattern = "Precedence: ([\w-]+)"
    # Match Header with Regex Pattern
    $spfResult = if ( $quarantineMessageHeader -match $spfPattern) { $matches[1] }
    $dkimResult = if ( $quarantineMessageHeader -match $dkimPattern) { $matches[1] }
    $dmarcResult = if ($quarantineMessageHeader -match $dmarcPattern) { $matches[1] }
    $CompAuthResult = if ($quarantineMessageHeader -match $CompAuthPattern) { $matches[1] }
    $PrecedenceResult= if ($quarantineMessageHeader -match  $PrecedencePattern) { $matches[1] }

    # Create Custom Object to store the data
    $FinalResults = New-Object -TypeName PSObject -Property @{
                ReceivedTime = $Result.ReceivedTime
                SenderAddress = $Result.SenderAddress
                RecipientAddress = $Result.RecipientAddress
                Type = $Result.Type
                MessageId =  $Result.MessageId
                Identity = $Result.Identity
                SPF = $spfResult
                DKIM = $dkimResult
                DMARC = $dmarcResult
                CompAuth = $CompAuthResult
                Precedence = $PrecedenceResult
    
    }
    # Export Data to a fil
    $FinalResults | Select ReceivedTime,SenderAddress,RecipientAddress,Type,SPF,DKIM,DMARC,CompAuth,Precedence,MessageId,Identity | Export-CSV $Outfile -Append -NoTypeInformation -Delimiter ";"  -Encoding UTF8
   
} # Foreach
