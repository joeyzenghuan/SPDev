1.	$tenant = "ericsson"
$siteUrl = "https://ericsson.sharepoint.com/sites/NDAprojects_Restored2 "

Connect-SPOService https://$tenant-admin.sharepoint.com

# parameter can be ReadOnly, NoAccess, or Unlock
Set-SPOSite $siteUrl -LockState " Unlock "
