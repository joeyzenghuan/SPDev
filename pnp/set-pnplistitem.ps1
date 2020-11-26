$username = "admin@M365x502029.onmicrosoft.com"  
$password = "Ms\\\qwert"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)

Connect-PnPOnline -Url https://m365x502029.sharepoint.com/sites/modernTeamSite -Credential $Cred

Get-PnPListItem -List "doc1" -Fields "FileRef","Title","IsPendingDlpScan"



$AllItems = Get-PnPListItem -List "doc1" 
foreach ($Item in $AllItems) {
    Write-Host  $Item["FileRef"] -ForegroundColor Green
    Write-Host  $Item["IsPendingDlpScan"] -ForegroundColor Green
    Write-Host  $Item["AccessPolicy"] -ForegroundColor Green
    #Write-Host  $Item.IsPendingDlpScan -ForegroundColor Red
    #Get-PnPProperty -ClientObject $Item -Property IsPendingDlpScan
}


