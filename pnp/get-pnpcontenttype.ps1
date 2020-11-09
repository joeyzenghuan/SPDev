$username = "admin@M365x502029.onmicrosoft.com"  
$password = "Ms\\\qwert"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)


Connect-PnPOnline -Url https://m365x502029.sharepoint.com/sites/teamsite2 -Credential $Cred

Get-PnPContentType | ?{$_.Name -like '*Signatures*'} | select Name, Id, group

Get-PnPContentType | ?{$_.Name -like '*feedback*'} | select Name, Id, group

Get-PnPContentType | ogv

remove-pnpcontenttype -Identity "0x01010400A10D4539FA5CFD439D5EA6A2D1FC0026"
