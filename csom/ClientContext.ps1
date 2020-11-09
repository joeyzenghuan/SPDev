$siteURL = "https://M365x502029.sharepoint.com/sites/teamsite2"
$username = "admin@M365x502029.onmicrosoft.com"  

$securePassword = Read-Host -Prompt "Enter password" -AsSecureString
$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 

$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL) 
$clientContext.credentials = $creds


$pushTenantManager = new-object Microsoft.SharePoint.Client.Search.ContentPush.PushTenantManager $clientContext

$info = $pushTenantManager.GetPushServiceInfo()
$info.Retrieve("EndpointAddress")
$info.Retrieve("TenantId")
$info.Retrieve("AuthenticationRealm")
$info.Retrieve("ValidContentEncryptionCertificates")

$clientContext.ExecuteQuery()
$info | fl