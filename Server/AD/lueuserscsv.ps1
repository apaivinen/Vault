$users = Import-CSV -LiteralPath ".\users.csv"
$laskuri = 0
Foreach($user in $users){
    $laskuri = $laskuri + 1
	Write-Host $laskuri " The first name is: " $user.FirstName " department: " $user.Department
}