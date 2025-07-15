<#
.SYNOPSIS
    Extracts Power BI activity logs for the operations 'CreateReport' and 'ViewReport' over the last defined number of days.

.DESCRIPTION
    This script uses the Get-PowerBIActivityEvent cmdlet to query Power BI audit logs for specific user activities 
    ('CreateReport' and 'ViewReport') over a customizable number of past days (limited to 28).
    The results are exported to a CSV file including selected metadata such as user ID, operation name, and timestamp.

.NOTES
    File Name      : Extract-PowerBI-CreateViewReport.ps1
    Author         : DEVILLES Tristan
    Creation Date  : 10/07/2025
    Last Modified  : 10/07/2025
    Version        : 1.0
    PowerShell     : 5.1+

.MODIFICATION HISTORY
    - 10/07/2025 : Initial version to extract CreateReport and ViewReport activities from Power BI logs.
#>


# Main script starts here 

# Start timer
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Source : https://learn.microsoft.com/en-us/power-bi/guidance/admin-activity-log?utm_source=chatgpt.com#sample-request-2
# The source details all the process. 

# Number of days to retrieve information
# Limited to 28 days before the current date (https://learn.microsoft.com/en-us/power-bi/guidance/admin-activity-log?utm_source=chatgpt.com#sample-request-2)
$NbrOfDaysToCheck = 28

# All Activities : https://learn.microsoft.com/en-us/fabric/admin/operation-list
# Choose the activity in 'Operation Name' column.

# Here we want only CreateReport and ViewReport
$Activity1 = 'CreateReport'
$Activity2 = 'ViewReport'

# Initialize array to store all the results for each activities 
$FullResults = @() 

# Use today to start counting back the number of days to check:
$DayUTC = (([datetime]::Today.ToUniversalTime()).Date)

# OutFile 
$Outfile = "C:\Users\Tristan.DEVILLES\OneDrive - VINCI Energies\Projets\PowerBI\ExtractUsersActivities-$NbrOfDaysToCheck.csv"


For($LoopNbr=0; $LoopNbr -le $NbrOfDaysToCheck; $LoopNbr++)
{
    $PeriodStart=$DayUTC.AddDays(-$LoopNbr)
    $ActivityDate=$PeriodStart.ToString("yyyy-MM-dd")
    Write-Verbose "Checking $ActivityDate" -Verbose 

    #Get activity 1 and append its results into the full resultset:
    $Activity1Results = @()
    $Activity1Results += Get-PowerBIActivityEvent `
        -StartDateTime ($ActivityDate+'T00:00:00.000') `
        -EndDateTime ($ActivityDate+'T23:59:59.999') `
        -ActivityType $Activity1 | ConvertFrom-Json
    If ($null -ne $Activity1Results) {$FullResults += $Activity1Results}
    
    #Get activity 2 and append its results into the full resultset:
    $Activity2Results = @()
    $Activity2Results += Get-PowerBIActivityEvent `
        -StartDateTime ($ActivityDate+'T00:00:00.000') `
        -EndDateTime ($ActivityDate+'T23:59:59.999') `
        -ActivityType $Activity2 | 
    ConvertFrom-Json
    If ($null -ne $Activity2Results) {$FullResults += $Activity2Results}  

}  

# Select properties that interest us :
$FullResults | Select Operation, Workload, UserId, Activity, WorkspaceName, CreationTime | Export-CSV $Outfile -NoTypeInformation -Delimiter ";"

# Stop timer and display elapsed time
$Stopwatch.Stop()
Write-Host "Durée d'exécution du script : $($Stopwatch.Elapsed.ToString())"