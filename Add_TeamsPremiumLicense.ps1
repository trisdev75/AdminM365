<#
.SYNOPSIS
    Add TeamsPremium license

.DESCRIPTION
    Add TeamsPremium license for users

.NOTES
    File Name      : Add_TeamsPremiumLicense.ps1
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
    Add user in the inputFile
    run .\Add_TeamsPremiumLicense.ps1
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


# Main script starts here 

# Connect Online Services
Connect-MgGraph
Connect-ExchangeOnline

# Files
$InputFile = #FILE TO IMPORT
$OutputFile = #PATH TO OUTPUT
$LogFile = #PATH TO LOG FILE

# Find TeamsPremium Sku
$TeamsPremiumSku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'Microsoft_Teams_Premium'

$Users = import-csv $InputFile
#CSV
#UserPrincipalName;


Foreach($user in $users)
{
    $UserMailbox = $user.UserPrincipalName
    $UserPrincipalName = (Get-Mailbox -identity $UserMailbox).UserPrincipalName
    try{
        # Add license Teams 
        Set-MgUserLicense -UserId $UserPrincipalName -AddLicenses @{SkuId = $TeamsPremiumSku.SkuId} -RemoveLicenses @()
        Write-log -Message "Add TeamsPremium license for $UserPrincipalName" -Etat OK
    
    }
    catch{
        Write-log -Message "Add TeamsPremium license for $UserPrincipalName" -Etat ERROR
    
    }

}# Foreach