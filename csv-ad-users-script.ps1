Import-Module ActiveDirectory

$userCsv = 'C:\ps\users.csv'
$ouCSV = 'C:\ps\ou.csv'
$groupsCSV = 'C:\ps\groups.csv'
$dcPath = 'DC=rquinzio,DC=lan'
$ouPath =  'OU=GROUPES,DC=rquinzio,DC=lan'
$groups = Import-Csv $groupsCSV
$ouNames = Import-Csv $ouCSV
$users = Import-Csv $userCsv

foreach($ou in $ouNames){
    New-ADOrganizationalUnit -Name $ou.name -Path $dcPath -ProtectedFromAccidentalDeletion $True
    }

foreach ($group in $groups){
    New-ADGroup -Name $group.name -Path $ouPath -GroupScope $group.scope -GroupCategory $group.category
    }

foreach ($user in $users) {

    $firstName = $user.firstname
    $lastName = $user.lastname
    [boolean]$changePassword = [System.Convert]::ToBoolean($user.chpasswdlogon)
    [boolean]$enabled = [System.Convert]::ToBoolean($user.enabled)

    New-ADUser `
    -Name "$firstName $lastName" `
    -SamAccountName $user.username `
    -GivenName $user.firstname `
    -Surname $user.lastname `
    -AccountPassword (ConvertTo-SecureString $user.password -AsPlainText -Force) `
    -ChangePasswordAtLogon $changePassword `
    -Enabled $enabled `
    -Path $user.ou
}

    foreach ($user in $users) {
    if ([string]($user.group2) -like "CN*") {
        Add-ADGroupMember -Identity $user.group2 -Members $user.userPath}
        Add-ADGroupMember -Identity $user.group1 -Members $user.userPath
}

