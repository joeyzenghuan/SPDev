# https://www.sharepointdiary.com/2019/08/connect-sharepoint-online-powershell-using-mfa.html

Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\2.26.1805.1\OfficeDevPnP.Core.dll"

$SiteURL = "https://m365x502029.sharepoint.com/sites/modernTeamSite2"

$AuthenticationManager = new-object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $AuthenticationManager.GetWebLoginClientContext($SiteURL)

$Ctx.Load($Ctx.Web)
$Ctx.ExecuteQuery()
 
Write-Host $Ctx.Web.Title