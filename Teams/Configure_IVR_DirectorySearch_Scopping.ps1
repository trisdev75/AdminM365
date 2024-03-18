<#
.SYNOPSIS
    Configure IVR + Directory Search and scoping for one group

.DESCRIPTION
    For an existing Autoattendant, Configure IVR feature and the Directory search scopped for one group.

.NOTES
    File Name      : Configure_IVR_DirectorySearch_Scopping.ps1
    Author         : trisdev75
    Created        : 10/01/2024
    Last Modified  : NA
    Version        : 1.0
    PowerShell Version: 5.1
    Changelog      : 
        - Date: NA

.PARAMETER Name
    No Parameters needed

.EXAMPLE
    Open the script, change the settings you want.
    run .\Configure_IVR_DirectorySearch_Scopping.ps1
#>




Connect-MicrosoftTeams

$AA_Name = "AUTO ATTENDANT NAME"
$AA_Instance = Get-CsAutoAttendant | Where-Object { $_.Name -eq $AA_Name}
$AA_Identity = $AA_Instance.Identity

#IVR config
#Tone1
$Option1Target = "USER1"
$MenuOption1Target = (Get-CsOnlineUser $Option1Target).Identity
$MenuOption1Entity = New-CsAutoAttendantCallableEntity -Identity $MenuOption1Target -Type user
$MenuOption1 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone1 -CallTarget $MenuOption1Entity

#Tone2
$Option2Target = "USER2"
$MenuOption2Target = (Get-CsOnlineUser $Option2Target).Identity
$MenuOption2Entity = New-CsAutoAttendantCallableEntity -Identity $MenuOption2Target -Type user
$MenuOption2 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone2 -CallTarget $MenuOption2Entity

#IVR Menu
$Default_MenuPromptText = "Bonjour, pour contacter USER1, merci de taper 1, pour USER2 taper 2, sinon dites le nom de la personne que vous souhaitez joindre."
$Default_MenuPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $Default_MenuPromptText
$Default_Menu = New-CsAutoAttendantMenu -Name "Default menu" -MenuOptions @($MenuOption1, $MenuOption2) -Prompts $Default_MenuPrompt -EnableDialByName -DirectorySearchMethod ByName -Force $true

#AA Greeting
$Default_GreetingPromptText = "Bienvenue sur le POC de standard!"
$Default_GreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $Default_GreetingPromptText 

#Default Call flow
$Default_CallFlow = New-CsAutoAttendantCallFlow -Name "$AA_Name Default call flow" -Menu $Default_Menu -Greetings @($Default_GreetingPrompt) 
$AA_Instance.VoiceResponseEnabled = $true
$AA_Instance.DefaultCallFlow = $Default_CallFlow

Set-CsAutoAttendant -Instance $AA_Instance



###SCOPING GROUP
$GroupName = "GROUPNAME"
$GroupID = Find-CsGroup -SearchQuery $GroupName | % { $_.Id }
$dialScope = New-CsAutoAttendantDialScope -GroupScope -GroupIds @($GroupID)
$AA_Instance.DirectoryLookupScope.InclusionScope = $dialscope

Set-CsAutoAttendant -Instance $AA_Instance






