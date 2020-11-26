# Credits to Adnan Amin and Salaudeen Rajack for their original ideas 
# This script gets permissions for all users in a web application on all objects (web application > site collection > web > list/library > item)  
# Note that unlike Salaudeen's original script, this script shows Limited Access permissions. 
# Note that AD groups and users in AD groups are not included 
 
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue 
 
Function GetUserAccessReport($WebAppURL, $FileUrl) 
{ 
    Write-Host "Generating permission report..." 
 
    #Get All Site Collections of the WebApp 
    $SiteCollections = Get-SPSite -WebApplication $WebAppURL -Limit All 
 
    #Write CSV- TAB Separated File) Header 
    "URL`tSite/List/Folder/Item`tTitle/Name`tPermissionType`tPermissions `tLoginName" | out-file $FileUrl 
 
    #Check Web Application Policies 
    $WebApp= Get-SPWebApplication $WebAppURL 
 
    foreach ($Policy in $WebApp.Policies)  
      { 
        $PolicyRoles=@() 
        foreach($Role in $Policy.PolicyRoleBindings) 
        { 
            $PolicyRoles+= $Role.Name +";" 
        } 
         
        "$($AdminWebApp.URL)`tWeb Application`t$($AdminSite.Title)`tWeb Application Policy`t$($PolicyRoles)`t$($Policy.UserName)" | Out-File $FileUrl -Append 
    } 
 
    #Loop through all site collections 
    foreach($Site in $SiteCollections)  
    { 
      #Check Whether the Search User is a Site Collection Administrator 
      foreach($SiteCollAdmin in $Site.RootWeb.SiteAdministrators) 
          { 
            "$($Site.RootWeb.Url)`tSite`t$($Site.RootWeb.Title)`tSite Collection Administrator`tSite Collection Administrator`t$($SiteCollAdmin.LoginName)" | Out-File $FileUrl -Append 
        } 
   
       #Loop throuh all Sub Sites 
       foreach($Web in $Site.AllWebs)  
       {     
            if($Web.HasUniqueRoleAssignments -eq $True) 
            { 
                #Get all the users granted permissions to the list 
                foreach($WebRoleAssignment in $Web.RoleAssignments )  
                {  
                    #Is it a User Account? 
                    if($WebRoleAssignment.Member.userlogin)     
                    { 
                        #Get the Permissions assigned to user 
                        $WebUserPermissions=@() 
                        foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings) 
                        { 
                            $WebUserPermissions += $RoleDefinition.Name +";" 
                        } 
                         
                        #Send the Data to Log file 
                        "$($Web.Url)`tSite`t$($Web.Title)`tDirect Permission`t$($WebUserPermissions) `t$($WebRoleAssignment.Member.LoginName)" | Out-File $FileUrl -Append 
                    } 
                    #Its a SharePoint Group, So search inside the group and check if the user is member of that group 
                    else   
                    { 
                        foreach($user in $WebRoleAssignment.member.users) 
                        { 
                            #Get the Group's Permissions on site 
                            $WebGroupPermissions=@() 
                            foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings) 
                            { 
                                $WebGroupPermissions += $RoleDefinition.Name +";" 
                            } 
                             
                            #Send the Data to Log file 
                            "$($Web.Url)`tSite`t$($Web.Title)`tMember of $($WebRoleAssignment.Member.Name) Group`t$($WebGroupPermissions)`t$($user.LoginName)" | Out-File $FileUrl -Append 
                        } 
                    } 
                } 
            } 
                 
            #********  Check Lists, Folders, and Items with Unique Permissions ********/ 
            foreach($List in $Web.lists) 
            { 
                if($List.HasUniqueRoleAssignments -eq $True -and ($List.Hidden -eq $false)) 
                { 
                    #Get all the users granted permissions to the list 
                    foreach($ListRoleAssignment in $List.RoleAssignments )  
                    {  
                        #Is it a User Account? 
                        if($ListRoleAssignment.Member.userlogin)     
                        { 
                            #Get the Permissions assigned to user 
                            $ListUserPermissions=@() 
                            foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings) 
                            { 
                                $ListUserPermissions += $RoleDefinition.Name +";" 
                            } 
                             
                            #Send the Data to Log file 
                            "$($List.ParentWeb.Url)/$($List.RootFolder.Url)`tList`t$($List.Title)`tDirect Permission`t$($ListUserPermissions) `t$($ListRoleAssignment.Member)" | Out-File $FileUrl -Append 
                        } 
                        #Its a SharePoint Group, So search inside the group and check if the user is member of that group 
                        else   
                        { 
                            foreach($user in $ListRoleAssignment.member.users) 
                            { 
                                #Get the Group's Permissions on site 
                                $ListGroupPermissions=@() 
                                foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings) 
                                { 
                                    $ListGroupPermissions += $RoleDefinition.Name +";" 
                                } 
                                 
                                #Send the Data to Log file 
                                "$($List.ParentWeb.Url)/$($List.RootFolder.Url)`tList`t$($List.Title)`tMember of $($ListRoleAssignment.Member.Name) Group`t$($ListGroupPermissions)`t$($user.LoginName)" | Out-File $FileUrl -Append 
                            } 
                        }     
                    } 
                } 
                 
                #Get Folder level permissions 
                foreach($Folder in $List.folders) 
                { 
                    if($Folder.HasUniqueRoleAssignments -eq $True) 
                    { 
                        #Get all the users granted permissions to the folder 
                        foreach($FolderRoleAssignment in $Folder.RoleAssignments )  
                        {  
                            #Is it a User Account? 
                            if($FolderRoleAssignment.Member.userlogin)     
                            { 
                                #Get the Permissions assigned to user 
                                $FolderUserPermissions=@() 
                                foreach ($RoleDefinition  in $FolderRoleAssignment.RoleDefinitionBindings) 
                                { 
                                    $FolderUserPermissions += $RoleDefinition.Name +";" 
                                } 
                                 
                                #Send the Data to Log file 
                                "$($Folder.Web.Url)/$($Folder.Url)`tFolder`t$($Folder.Title)`tDirect Permission`t$($FolderUserPermissions) `t$($FolderRoleAssignment.Member)" | Out-File $FileUrl -Append 
                            } 
                            #Its a SharePoint Group, So search inside the group and check if the user is member of that group 
                            else   
                            { 
                                foreach($user in $FolderRoleAssignment.member.users) 
                                { 
                                    #Get the Group's Permissions on site 
                                    $FolderGroupPermissions=@() 
                                    foreach ($RoleDefinition  in $FolderRoleAssignment.RoleDefinitionBindings) 
                                    { 
                                        $FolderGroupPermissions += $RoleDefinition.Name +";" 
                                    } 
                                     
                                    #Send the Data to Log file 
                                    "$($Folder.Web.Url)/$($Folder.Url)`tFolder`t$($Folder.Title)`tMember of $($FolderRoleAssignment.Member.Name) Group`t$($FolderGroupPermissions)`t$($user.LoginName)" | Out-File $FileUrl -Append 
 
                                } 
                            }     
                        } 
                    } 
                } 
                 
                #Get Item level permissions 
                foreach($Item in $List.items) 
                { 
                    if($Item.HasUniqueRoleAssignments -eq $True) 
                    { 
                        #Get all the users granted permissions to the item 
                        foreach($ItemRoleAssignment in $Item.RoleAssignments )  
                        {  
                            #Is it a User Account? 
                            if($ItemRoleAssignment.Member.userlogin)     
                            { 
                                #Get the Permissions assigned to user 
                                $ItemUserPermissions=@() 
                                foreach ($RoleDefinition  in $ItemRoleAssignment.RoleDefinitionBindings) 
                                { 
                                    $ItemUserPermissions += $RoleDefinition.Name +";" 
                                } 
 
                                #Prepare item's absolute Url and Name 
                                $ItemDispForm = $Item.ParentList.Forms | where { $_.Type -eq "PAGE_DISPLAYFORM" } | Select-Object -first 1 
                                if ($ItemDispForm.Url) 
                                { 
                                    $ItemUrl = "$($Item.Web.Url)/$($ItemDispForm.Url)?ID=$($Item.ID)"  
                                } 
                                else 
                                { 
                                    $ItemUrl = "$($Item.Url)" 
                                } 
 
                                if ($Item.Name) 
                                { 
                                    $ItemTitle = $Item.Name 
                                } 
                                else 
                                { 
                                    $ItemTitle = $Item.Title 
                                } 
                                 
                                #Send the Data to Log file 
                                "$($ItemUrl)`tItem`t$($ItemTitle)`tDirect Permission`t$($ItemUserPermissions) `t$($ItemRoleAssignment.Member)" | Out-File $FileUrl -Append 
                            } 
                            #Its a SharePoint Group, So search inside the group and check if the user is member of that group 
                            else   
                            { 
                                foreach($user in $ItemRoleAssignment.member.users) 
                                { 
                                    #Get the Group's Permissions on site 
                                    $ItemGroupPermissions=@() 
                                    foreach ($RoleDefinition  in $ItemRoleAssignment.RoleDefinitionBindings) 
                                    { 
                                        $ItemGroupPermissions += $RoleDefinition.Name +";" 
                                    } 
                                     
                                    #Prepare item's absolute Url and Name 
                                    $ItemDispForm = $Item.ParentList.Forms | where { $_.Type -eq "PAGE_DISPLAYFORM" } | Select-Object -first 1 
                                    if ($ItemDispForm.Url) 
                                    { 
                                        $ItemUrl = "$($Item.Web.Url)/$($ItemDispForm.Url)?ID=$($Item.ID)"  
                                    } 
                                    else 
                                    { 
                                        $ItemUrl = "$($Item.Url)" 
                                    } 
 
                                    if ($Item.Name) 
                                    { 
                                        $ItemTitle = $Item.Name 
                                    } 
                                    else 
                                    { 
                                        $ItemTitle = $Item.Title 
                                    } 
 
                                    #Send the Data to Log file 
                                    "$($ItemUrl)`tItem`t$($ItemTitle)`tMember of $($ItemRoleAssignment.Member.Name) Group`t$($ItemGroupPermissions)`t$($user.LoginName)" | Out-File $FileUrl -Append 
 
                                } 
                            }     
                        } 
                    } 
                } 
            } 
        }     
    } 
} 
 
#Call the function to Check User Access 
GetUserAccessReport "http://mysite" "C:\SharePoint_Permission_Report.csv" 
Write-Host "Complete" 