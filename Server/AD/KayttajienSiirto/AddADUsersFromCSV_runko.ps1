$users=Import-CSV –LiteralPath “C:\users.csv” #CSV-file which contains users
$count = 0  
$errorcount = 0
$OUpath = "OU=userss,DC=azure2,DC=local"


foreach ($user in $users){
    try{
    $GivenName = $user.GivenName
    $Surname = $user.Surname
    $UPN = $user.UserPrincipalName
    
    New-ADUser $givenName -GivenName $GivenName -Surname $Surname -UserPrincipalName $upn -ChangePasswordAtLogon $true -Path $OUpath
  
    #Remove-ADUser $GivenName -confirm:$false # this line is for testing purposes only
    
    if ($_.Exception.Message -eq $null) {$count = $count +1}
    }
    catch{
    $errorcount = $errorcount +1
    write-host $_.Exception.Message " | "$GivenName")"
    }
}
write-host $count " users added"
write-host $errorcount " errors"

