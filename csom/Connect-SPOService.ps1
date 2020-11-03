##--------------- credential  ------------
$username = "admin@M365x502029.onmicrosoft.com"  
#$password = "Ms\\\qwert"
$password = Read-Host -Prompt "Enter password" -AsSecureString
#$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
#$credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $password -asplaintext -force)
$credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $password
Connect-SPOService -url https://M365x502029-admin.sharepoint.com -Credential $credential
