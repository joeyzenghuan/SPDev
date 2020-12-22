#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Function to Get Folder Permissions
Function Get-SPOFolderPermission($Folder) {
    Try {
        #Check if Folder has unique permissions
        $Folder.ListItemAllFields.Retrieve("HasUniqueRoleAssignments")
        $Ctx.ExecuteQuery()  

        "`t`t$($Folder.ServerRelativeUrl)`t$($Folder.ListItemAllFields.HasUniqueRoleAssignments)`t`t`t`t`t`t`t"  | Out-File $FileUrl -Append 
                
        if ($Folder.ListItemAllFields.HasUniqueRoleAssignments -eq $true) {

            Write-host -ForegroundColor Red "Folder has unique Permissions!" 

            #Get permissions assigned to the Folder
            $RoleAssignments = $Folder.ListItemAllFields.RoleAssignments
            $Ctx.Load($RoleAssignments)
            $Ctx.ExecuteQuery()

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
                $LoginName = $RoleAssignment.Member.LoginName
                $LoginTitle = $RoleAssignment.Member.Title

                if ($RoleAssignment.Member.PrincipalType -eq "SharePointGroup") { 
                    Write-Host ""
                    Write-Host -f Cyan "PermissionLevels:" $PermissionLevels
                    Write-Host -f Green "SharePointGroup:"  $LoginName
               
                    "`t`t`t`t$($PermissionLevels)`t$($RoleAssignment.Member.PrincipalType)`t$($LoginName)`t`t`t`t"  | Out-File $FileUrl -Append 

                    $group = $Ctx.Web.SiteGroups.GetByName($RoleAssignment.Member.Title)     
                    $Ctx.Load($group) 
                    $users = $group.Users 
                    $Ctx.Load($users) 
                    $Ctx.ExecuteQuery() 

                    Write-Host -f Green "Group Members:"

                    foreach ($user in $users) { 

                        #  "SiteUrl`tLibraryUrl`tFolderUrl`tUniqueOrNot`tPermissionLevels`tTargetType`tLoginName`t
                        # LoginId`tMemberLoginName`tMemberLoginId" | out-file $FileUrl 
 
                        write-host -f DarkGray $user.LoginName + $user.Title   
                        "`t`t`t`t`t`t`t`t$($user.LoginName)`t$($user.Title)`t"  | Out-File $FileUrl -Append 
                    } 
                }
                else {
                    if ($RoleAssignment.Member.PrincipalType -eq "User") {
                        Write-Host ""
                        Write-Host -f Cyan "PermissionLevels:" $PermissionLevels
                        Write-Host -f Red "Direct Permission for SPUser:" $LoginName

                        #  "SiteUrl`tLibraryUrl`tFolderUrl`tUniqueOrNot`tPermissionLevels`tTargetType`tLoginName`t
                        # LoginId`tMemberLoginName`tMemberLoginId" | out-file $FileUrl 
                        "`t`t`t`t$($PermissionLevels)`t$($RoleAssignment.Member.PrincipalType)`t$($LoginName)`t$($LoginTitle)`t`t`t"  | Out-File $FileUrl -Append 
                    }
                    else {
                        Write-Host ""
                        Write-Host -f Cyan "PermissionLevels:" $PermissionLevels
                        write-host -f Red "Neither SPGroup or User: " $LoginName
                        "`t`t`t`t$($PermissionLevels)`t$($RoleAssignment.Member.PrincipalType)`t$($LoginName)`t$($LoginTitle)`t`t`t"  | Out-File $FileUrl -Append 
                    }
                } 
            }

        }
        else {
            Write-host -ForegroundColor Green "No unique Permissions, inherited from Parent!" 
            "`t`t`t`t`t`t`t`t`t`t"  | Out-File $FileUrl -Append 
        }    
    }
    Catch {
        write-host -f Red "Error Getting Folder Permissions!" $_.Exception.Message
    }
}


function RecurseSubFolders ($folder) {
    Write-host -f Yellow "folder URL:" $folder.ServerRelativeUrl
    Get-SPOFolderPermission $folder 

    $Ctx.Load($folder.Folders)
    $Ctx.ExecuteQuery()

    if ($folder.Folders.Count -eq 0) {  
    }
    else {
        foreach ($subfolder in $folder.Folders) {
            $Ctx.Load($subfolder)
            $Ctx.ExecuteQuery()
            RecurseSubFolders $subfolder
        }     
    }
}

function Get-AllFoldersInListUsingCaml($List) {
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

function Get-PermissionFromList($List) {
    $RootFolders = $List.RootFolder.Folders 
    $Ctx.Load($RootFolders)
    $Ctx.ExecuteQuery()
    
    foreach ($RootFolder in $RootFolders) {
        RecurseSubFolders $RootFolder
    }

}

# #Login if MFA is not required
# $Cred = Get-Credential
# #Setup the context
# $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
# $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)

#Set Config Parameters
$SiteURL = "https://m365x502029.sharepoint.com/sites/modernTeamSite2"

# Login if MFA is required
Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\2.26.1805.1\OfficeDevPnP.Core.dll"
$AuthenticationManager = new-object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $AuthenticationManager.GetWebLoginClientContext($SiteURL)

# csv path
$FileUrl = "C:\Users\zehua\SPDev\get-allperm4.csv"
# csv column names initialization
"SiteUrl`tLibraryName`tFolderUrl`tUniqueOrNot`tPermissionLevels`tTargetType`tLoginName`tLoginTitle`tMemberLoginName`tMemberTitle" | out-file $FileUrl 

"$($SiteURL)`t`t`t`t`t`t`t`t`t`t"  | Out-File $FileUrl -Append 

# $ListName = "Documents"
$ListName = "DocLib"
#Get the List
$List = $Ctx.web.Lists.GetByTitle($ListName)
$Ctx.Load($List)
$Ctx.ExecuteQuery()

Write-host "Library name:" $List.Title
"`t$($List.Title)`t`t`t`t`t`t`t`t`t"  | Out-File $FileUrl -Append 
Get-PermissionFromList $List









