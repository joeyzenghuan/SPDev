<#
Checked in by: majoshi
Date Created: 01/11/2018

Product Area Tags: Sites, 

Technology Tags: PowerShell, 

Use Case: 
Retrieve Usage reports for each user and specifically FileAccessed,PageViewed,PageViewedExtended

Description: 

Keywords: 

Code Example Disclaimer:
Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED 'AS IS'
-This is intended as a sample of how code might be written for a similar purpose and you will need to make changes to fit to your requirements. 
-This code has not been tested.  This code is also not to be considered best practices or prescriptive guidance.  
-No debugging or error handling has been implemented.
-It is highly recommended that you FULLY understand what this code is doing  and use this code at your own risk.

#>

$Username = "admin@M365x502029.onmicrosoft.com"
$Password = ConvertTo-SecureString 'Ms\\\qwert' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $Username, $Password
 
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $session
Connect-MsolService -Credential $LiveCred
 
$extUsers = Get-MsolUser | Where-Object {$_.UserPrincipalName -notlike "*#EXT#*" }
 
$extUsers | ForEach {
        
    $OutputFile = "D:\" + $_.DisplayName + ".csv"

    #working
    #========
    #$auditEventsForUser = Search-UnifiedAuditLog -EndDate $((Get-Date)) -StartDate $((Get-Date).AddDays(-7)) -UserIds $_.UserPrincipalName  #To get All Audit Operations
    #$auditEventsForUser = Search-UnifiedAuditLog -EndDate $((Get-Date)) -StartDate $((Get-Date).AddDays(-7)) -UserIds $_.UserPrincipalName -RecordType SharePointFileOperation -Operations FileAccessed,PageViewed,PageViewedExtended
    $auditEventsForUser = Search-UnifiedAuditLog -EndDate $((Get-Date)) -StartDate $((Get-Date).AddDays(-7)) -UserIds $_.UserPrincipalName -RecordType SharePoint -Operations FileAccessed,PageViewed,PageViewedExtended
    #========

    Write-Host "Events for" $_.DisplayName "created at" $_.WhenCreated
 
    $ConvertedOutput = $auditEventsForUser | Select-Object -ExpandProperty AuditData | ConvertFrom-Json

    $ConvertedOutput | Select-Object CreationTime,UserId,Operation,Workload,ObjectID,SiteUrl,SourceFileName,ClientIP,UserAgent | Export-Csv $OutputFile -NoTypeInformation -Append
}
 
Remove-PSSession $session