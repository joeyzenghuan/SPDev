
#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Function to Get Folder Permissions
Function Get-SPOFolderPermission($Folder) {
    Try {
               
        #Check if Folder has unique permissions
        $Folder.ListItemAllFields.Retrieve("HasUniqueRoleAssignments")
        $Ctx.ExecuteQuery()  
                
        if ($Folder.ListItemAllFields.HasUniqueRoleAssignments -eq $true) {
            Write-host -ForegroundColor Red "Folder has unique Permissions!" 
            #Get permissions assigned to the Folder
            $RoleAssignments = $Folder.ListItemAllFields.RoleAssignments
            $Ctx.Load($RoleAssignments)
            $Ctx.ExecuteQuery()
 
            Foreach ($RoleAssignment in $RoleAssignments) { 

                $Ctx.Load($RoleAssignment.Member)
                $Ctx.executeQuery()
 
                # $RoleAssignment.Member | gm
                #Get the User Type
                $PermissionType = $RoleAssignment.Member.PrincipalType
 
                #Get the Permission Levels assigned
                $Ctx.Load($RoleAssignment.RoleDefinitionBindings)
                $Ctx.ExecuteQuery()
                $PermissionLevels = ($RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name) -join ","
             
                #Get the User/Group Name
                #             $Name = $RoleAssignment.Member.Title # $RoleAssignment.Member.LoginName
                $LoginName = $RoleAssignment.Member.LoginName

                if ($RoleAssignment.Member.PrincipalType -eq "SharePointGroup") { 
                    Write-Host ""
                    Write-Host -f Cyan "PermissionLevels:" $PermissionLevels
                    Write-Host -f Green "SharePointGroup:"  $LoginName
               

                    $group = $Ctx.Web.SiteGroups.GetByName($RoleAssignment.Member.Title)     
                    $Ctx.Load($group) 
                    $users = $group.Users 
                    $Ctx.Load($users) 
                    $Ctx.ExecuteQuery() 

                    Write-Host -f Green "Group Members:"
                    foreach ($user in $users) { 

                        write-host -f DarkGray $user.LoginName + $user.Title                  
                    } 
                }
                else {
                    if ($RoleAssignment.Member.PrincipalType -eq "User") {
                        Write-Host ""
                        Write-Host -f Cyan "PermissionLevels:" $PermissionLevels
                        Write-Host -f Red "Direct Permission for SPUser:" $LoginName

                    }
                    else {
                        Write-Host ""
                        Write-Host -f Cyan "PermissionLevels:" $PermissionLevels
                        write-host -f Red "Neither SPGroup or User: " $LoginName
                    }
                } 
            }
        }
        else {
            Write-host -ForegroundColor Green "No unique Permissions, inherited from Parent!" 
        }           
    }
    Catch {
        write-host -f Red "Error Getting Folder Permissions!" $_.Exception.Message
    }
}


function FolderRecurse ($folder) {
    write-host -f Yellow "----"
    write-host -f Yellow "folder name:" $folder.Name
    write-host -f Yellow "folder URL:" $folder.ServerRelativeUrl
    
    Get-SPOFolderPermission $folder 

    $Ctx.Load($folder.Folders)
    $Ctx.ExecuteQuery()

    if ($folder.Folders.Count -eq 0) {
    
    }
    else {
        foreach ($subfolder in $folder.Folders) {
            $Ctx.Load($subfolder)
            $Ctx.ExecuteQuery()
            FolderRecurse -folder $subfolder 
        }     
    }
}

function Get-AllFoldersInList($List) {
    Try {

        #Define CAML Query to get all folders from list recursively
        $CAMLQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $CAMLQuery.ViewXml = "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='FSObjType'/><Value Type='Integer'>1</Value></Eq></Where></Query></View>"
     
        #Get All Folders from the List
        $Folders = $List.GetItems($CAMLQuery)
        $Ctx.Load($Folders)
        $Ctx.ExecuteQuery()
     
        #Iterate through Each Folder
        ForEach ($Folder in $Folders) {
            #Get the Folder's Server Relative URL
            Write-host -f Yellow $Folder.FieldValues['FileRef']

            $FolderTemp = $Ctx.Web.GetFolderByServerRelativeUrl($($Folder.FieldValues['FileRef']))

            $Ctx.Load($FolderTemp)
            $Ctx.ExecuteQuery()
            Get-SPOFolderPermission $FolderTemp
        }
    }
    catch {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }

}

# FolderRecurse -folder $Folder


#Set Config Parameters
$SiteURL = "https://m365x502029.sharepoint.com/sites/AB"
# $FolderRelativeURL = "/sites/modernTeamSite2/Shared Documents/1"

#Get Credentials to connect
$Cred = Get-Credential
 
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)

#Get the Folder
# $Folder = $Ctx.Web.GetFolderByServerRelativeUrl($FolderRelativeURL)
# $Ctx.Load($Folder)
# $Ctx.ExecuteQuery()

$ListName = "Documents"
#Get the List
$List = $Ctx.web.Lists.GetByTitle($ListName)
$Ctx.Load($List)
$Ctx.ExecuteQuery()
Get-AllFoldersInList($List)









