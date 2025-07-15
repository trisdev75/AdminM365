<#
.SYNOPSIS
    Export all Exchange Online Application Access Policies with application names and scoping details.

.DESCRIPTION
    This script connects to Exchange Online and Microsoft Graph, retrieves all Application Access Policies, resolves the AppId to get the display name of each registered application via Microsoft Graph, 
    and exports the scoping details to a CSV file for reporting or auditing purposes.

.NOTES
    File Name      : Export-EXOAppAccessPolicyScoping.ps1
    Author         : trisdev75
    Creation Date  : 15/07/2025
    Last Modified  : 15/07/2025
    Version        : 1.0
    PowerShell Version : 7.x / 5.1 (Windows PowerShell compatible)

.MODIFICATION HISTORY
    - 15/07/2025 : Initial version to export application access policy scoping from Exchange Online.
#>

Connect-ExchangeOnline

Connect-MgGraph
$Outfile = #Your export file here

$Scoping = Get-ApplicationAccessPolicy
$Results = @()

Foreach($App in $Scoping){

    $AppID = $App.AppId
    $ScopeIdentityRaw = $App.ScopeIdentityRaw

    
    # Extraire le GUID s'il est combiné avec un SID : format "SID;GUID"
    if ($ScopeIdentityRaw -match ";(?<Guid>[0-9a-fA-F-]{36})$") {
        $GuidOnly = $Matches['Guid']
    } else {
        $GuidOnly = $ScopeIdentityRaw
    }

    $AppName = (Get-MgApplication -Filter "AppId eq '$AppID'").DisplayName
    $Recipient = Get-Recipient -Identity $GuidOnly -ErrorAction Stop
    
    $ScopeInfo = [PSCustomObject]@{
        AppId = $AppID
        AppName = $AppName
        ScopeName = $App.scopeName
        AccessRight = $App.AccessRight
        ScopeIdentityRaw = $ScopeIdentityRaw
        TargetName = $Recipient.DisplayName
        TargetYpe = $Recipient.RecipientType
    }
    $Results += $ScopeInfo

}

$Results | Export-CSV $Outfile -NoTypeInformation -Delimiter ";"




