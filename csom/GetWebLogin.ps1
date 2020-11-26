https://www.sharepointdiary.com/2019/08/connect-sharepoint-online-powershell-using-mfa.html

Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\2.26.1805.1\OfficeDevPnP.Core.dll"
$AuthenticationManager = new-object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $AuthenticationManager.GetWebLoginClientContext($SiteURL)