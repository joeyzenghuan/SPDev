$siteURL = "https://M365x502029.sharepoint.com/sites/teamsite2"
$username = "admin@M365x502029.onmicrosoft.com"  

$securePassword = Read-Host -Prompt "Enter password" -AsSecureString
$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 

$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL) 
$clientContext.credentials = $creds

#Bind to the list
$list = $clientContext.Web.GetList("sites/teamsite2/testDocLib")
$clientContext.Load($list)
$clientContext.ExecuteQuery()

$site = $clientContext.Site
$clientContext.Load($site)
$clientContext.ExecuteQuery()

$web = $site.rootweb
$clientContext.Load($web)
$clientContext.ExecuteQuery()

$cts = $web.ContentTypes
$clientContext.Load($cts)
$clientContext.ExecuteQuery()

$ct = $cts.GetById("0x0101040043E203973C747F46AD4E439E67273A66")
$clientContext.Load($ct)
$clientContext.ExecuteQuery()

$web.ContentTypes.delete("0x0101040043E203973C747F46AD4E439E67273A66")
