#----------------------------

function Recurse ($folder) {
    Add-Content D:\url.txt $folder.ServerRelativeUrl
    Add-Content D:\number.txt $folder.ItemCount

    $context.Load($folder.Folders)
    $context.ExecuteQuery()
    if ($folder.Folders.Count -eq 0) {
        
    }
    else {
        foreach ($subfolder in $folder.Folders) {
            $context.Load($subfolder)
            $context.ExecuteQuery()
            Recurse -folder $subfolder 
        }     
    }
}
 

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Specify tenant admin and site URL
$User = "admin@M365x502029.onmicrosoft.com"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$SiteURL = "https://m365x502029.sharepoint.com/sites/teamsite2"
$DocLibName = "Documents"

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User, $Password)
$Context.Credentials = $Creds

$specificfolder = $Context.Web.GetFolderByServerRelativeUrl("/sites/teamsite2/Shared Documents/FolderInDocLib")
$context.Load($specificfolder)
$context.ExecuteQuery()

Recurse -folder $specificfolder

