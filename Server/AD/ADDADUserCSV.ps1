$users = Import-CSV -LiteralPath ".\users.csv"
$laskuri = 0
$Salasana = "Salasana1"
$SalattuSalasana = $Salasana | ConvertTo-SecureString -AsPlainText -Force
Foreach($user in $users){
    $laskuri = $laskuri + 1
	#Write-Host $laskuri " The first name is: " $user.FirstName " department: " $user.Department
    New-ADUser $user.FirstName -AccountPassword $SalattuSalasana -Department $user.department -GivenName $user.FirstName -Surname $user.LastName -ChangePasswordAtLogon $true 
}
Write-Host "Scripti lisäs " $laskuri "käyttäjää"