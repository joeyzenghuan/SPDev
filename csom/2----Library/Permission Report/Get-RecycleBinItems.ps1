#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
# #Login if MFA is not required
# $Cred = Get-Credential
# #Setup the context
# $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
# $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)

#Set Config Parameters
$SiteURL = "https://m365x502029.sharepoint.com/sites/modernTeamSite2"

# Login if MFA is required
#Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\2.26.1805.1\OfficeDevPnP.Core.dll"
$AuthenticationManager = new-object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $AuthenticationManager.GetWebLoginClientContext($SiteURL)

# csv path
$FileUrl = "C:\Users\zehua\SPDev\get-deletedfile1.csv"
# csv column names initialization
"SiteUrl`tName`tOriginalLocation`tDeletedByEmail`tDeletedDate" | out-file $FileUrl 

"$($SiteURL)`t`t`t`t` "  | Out-File $FileUrl -Append 

#Get the Site recycle bin
$Site = $Ctx.Site
$RecycleBinItems = $Site.RecycleBin
$Ctx.Load($Site)
$Ctx.Load($RecycleBinItems)
$Ctx.ExecuteQuery()

ForEach ($RecycleBinItem in $RecycleBinItems) {
    # $ItemUrl = $RecycleBinItem.DirName + "/" + $RecycleBinItem.LeafName
    # Write-host -f Yellow $ItemUrl
    Write-host -f Yellow $RecycleBinItem.LeafName
    "`t$($RecycleBinItem.LeafName)`t$($RecycleBinItem.DirName)`t$($RecycleBinItem.DeletedByEmail)`t$($RecycleBinItem.DeletedDate)"  | Out-File $FileUrl -Append 
}






