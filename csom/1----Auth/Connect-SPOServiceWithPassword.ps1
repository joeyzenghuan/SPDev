$username = "admin@M365x502029.onmicrosoft.com"  
$password = "Ms\\\qwert"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $(convertto-securestring $password -asplaintext -force)
Connect-SPOService -Url https://m365x502029-admin.sharepoint.com -Credential $cred

#------------------

$username = "admin@coralFang.onmicrosoft.com"  
$password = "sfQv3KY7zC"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $(convertto-securestring $password -asplaintext -force)
Connect-SPOService -Url https://coralfang-admin.sharepoint.com -Credential $cred





$url="https://m365x502029.sharepoint.com/sites/AUGTEST"
$NewSiteUrl="https://m365x502029.sharepoint.com/sites/AUGTEST&B"
$newTitle="AUGTEST&B"
Start-SPOSiteRename -Identity $url -NewSiteUrl $NewSiteUrl -NewSiteTitle $newTitle