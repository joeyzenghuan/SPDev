$username = "admin@M365x502029.onmicrosoft.com"  
$password = "Ms\\\qwert"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $(convertto-securestring $password -asplaintext -force)
Connect-SPOService -Url https://m365x502029-admin.sharepoint.com -Credential $cred

Get-SPOSite -Identity https://m365x502029-my.sharepoint.com/personal/brianj_m365x502029_onmicrosoft_com | fl


$username = "admin@a830edad9050849754E20022407.onmicrosoft.com"  
$password = "Xaso6707"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $(convertto-securestring $password -asplaintext -force)
Connect-SPOService -Url https://a830edad9050849754E20022407-admin.sharepoint.com -Credential $cred

Get-SPOSite -Identity https://a830edad9050849754e20022407-my.sharepoint.com/personal/joeyz_a830edad9050849754e20022407_onmicrosoft_com | fl


SPListItemCollection items = list.GetItems(query);

foreach (SPListItem item in items)
{
    SPField itemField;
    itemField = item.Fields["City"].ToString();   // returns "City" (!?!?)
}


#First Connect to SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell
$username = "admin@M365x502029.onmicrosoft.com" 
$password = "Ms\\\qwert"
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force 
$url = "https://m365x502029.sharepoint.com/sites/modernTeamSite"
$context = New-Object Microsoft.SharePoint.Client.ClientContext($url) 
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 
$context.Credentials = $credentials 

#Get the List and Items
$list = $Context.Web.Lists.GetByTitle("wfdisplayname")
$query = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery(1000) 
$items = $list.GetItems($query)
$context.Load($list)
$context.Load($items) 
$context.ExecuteQuery()

#Loop Trough the Items
foreach ($item in $items) {

if($item["Title"]  -eq "123")
    {
    #UserName is our Column Name of type People Picker
    $item["user1"].LookupId
    $item["user1"].Email
    $item["user1"].LookupValue
    $item["user1"].TypeId
    $item["Title"]
    }

}
