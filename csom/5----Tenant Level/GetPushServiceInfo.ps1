[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Search")
# [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Search.ContentPush")
$siteURL = "https://M365x502029.sharepoint.com"

#$username = "admin@M365x502029.onmicrosoft.com"  
$username = "aa@douniwang.xyz"  
$securePassword = Read-Host -Prompt "Enter password" -AsSecureString
$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 

$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL) 

$clientContext.credentials = $creds

$pushTenantManager = New-Object Microsoft.SharePoint.Client.Search.ContentPush.PushTenantManager $clientContext

$info = $pushTenantManager.GetPushServiceInfo()

$info.Retrieve("EndpointAddress")
$info.Retrieve("TenantId")
$info.Retrieve("AuthenticationRealm")
$info.Retrieve("ValidContentEncryptionCertificates")
$clientContext.ExecuteQuery()

$info | fl
 