##--------------- credential  ------------
$username = "admin@M365x502029.onmicrosoft.com"  
$password = Read-Host -Prompt "Enter password" -AsSecureString
$credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $password
Connect-SPOService -url https://M365x502029-admin.sharepoint.com -Credential $credential

get-spotenant | select MarkNewFilesSensitiveByDefault


set-spotenant -MarkNewFilesSensitiveByDefault BlockExternalSharing


