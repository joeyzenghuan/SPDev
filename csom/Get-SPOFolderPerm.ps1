#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Function to Get Folder Permissions
Function Get-SPOFolderPermission($Folder) {
        Try {
               
                #Get permissions assigned to the Folder
                $RoleAssignments = $Folder.ListItemAllFields.RoleAssignments
                $Ctx.Load($RoleAssignments)
                $Ctx.ExecuteQuery()
                $PermissionCollection = ""
                #Loop through each permission assigned and extract details
                $PermissionCollection = @()
                Foreach ($RoleAssignment in $RoleAssignments) { 
                        $Ctx.Load($RoleAssignment.Member)
                        $Ctx.executeQuery()
 
                        #Get the User Type
                        $PermissionType = $RoleAssignment.Member.PrincipalType
 
                        #Get the Permission Levels assigned
                        $Ctx.Load($RoleAssignment.RoleDefinitionBindings)
                        $Ctx.ExecuteQuery()
                        $PermissionLevels = ($RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name) -join ","
             
                        #Get the User/Group Name
                        #             $Name = $RoleAssignment.Member.Title # $RoleAssignment.Member.LoginName
                        $LoginName = $RoleAssignment.Member.LoginName
 
                        #Add the Data to Object
                        $Permissions = New-Object PSObject
                        #             $Permissions | Add-Member NoteProperty Name($Name)
                        $Permissions | Add-Member NoteProperty LoginName($LoginName)
                        $Permissions | Add-Member NoteProperty Type($PermissionType)
                        $Permissions | Add-Member NoteProperty PermissionLevels($PermissionLevels)
                        $PermissionCollection += $Permissions
                        
                }
               
                Return $PermissionCollection
                
        }
        Catch {
                write-host -f Red "Error Getting Folder Permissions!" $_.Exception.Message
        }
}
  
#Set Config Parameters
$SiteURL = "https://m365x502029.sharepoint.com/sites/modernTeamSite2"
$FolderRelativeURL = "/sites/modernTeamSite2/Shared Documents/1"

#Get Credentials to connect
$Cred = Get-Credential
 
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
#Get the Folder
$Folder = $Ctx.Web.GetFolderByServerRelativeUrl($FolderRelativeURL)
$Ctx.Load($Folder)
$Ctx.ExecuteQuery()

Get-SPOFolderPermission $Folder
  









