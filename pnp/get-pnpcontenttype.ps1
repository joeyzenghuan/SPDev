$username = "admin@M365x502029.onmicrosoft.com"  
$password = "Ms\\\qwert"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)


Connect-PnPOnline -Url https://m365x502029.sharepoint.com/sites/teamsite2 -Credential $Cred

Get-PnPContentType | ?{$_.Name -like '*Signatures*'} | select Name, Id

Get-PnPContentType | ogv
