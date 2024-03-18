<#
.SYNOPSIS
    List AzureAD Devices

.DESCRIPTION
    List azureAD devices. you can disable or delete also.

.NOTES
    File Name      : Get_AADDevices.ps1
    Author         : trisdev75
    Created        : 30/10/2023
    Last Modified  : NA
    Version        : 1.0
    PowerShell Version: 5.1
    Changelog      : 
        - Date: NA

.PARAMETER Name
    No Parameters needed

.EXAMPLE
    Add user in the inputFile
    run .\Add_CopilotLicense.ps1
#>


Connect-AzureAD

$Outfile = # File Path

$Date = Get-Date -Format dd-MM-yy
$dt = (Get-Date).AddDays(-182)


$Devices = Get-AZureADDevice -all:$true | Where-object {($_.ApproximateLastLogonTimeStamp -le $dt) -and (($_.DeviceOSType -eq "IPhone") -or ($_.DeviceOSType -eq "IPad") -or ($_.DeviceOSType -eq "iOS") -or ($_.DeviceOSType -like "*Android*"))}

foreach ($Device in $Devices) {
    
    $ObjectId = $Device.ObjectId
    $Owner = Get-AzureADDeviceRegisteredOwner -ObjectId $ObjectId | Select UserPrincipalname

    $Result = [pscustomobject]@{
        "Enabled" = $Device.AccountEnabled
        "ObjectId" = $ObjectId
        "DeviceId" = $Device.DeviceId
        "DeviceOSType" = $Device.DeviceOSType
        "DisplayName" = $Device.DisplayName
        "DevicetrustType" = $Device.DeviceTrustType
        "Owner" = $Owner
        "ApproximateLastLogontimeStamp" = $Device.ApproximateLastLogonTimeStamp
        } | Export-CSV $Outfile -Delimiter ";" -NoTypeInformation -Append

}# foreach

# To disable devices or delete devices Add this 2 lines inside the Foreach

# Disable a device
#Set-AzureADDevice -ObjectId $ObjectId -AccountEnabled $false

# Delete a device 
#Remove-AzureADDevice -ObjectId $ObjectId


