$users = Import-CSV -LiteralPath ".\users.csv"
$laskuri = 0
#salasanaan pitää keksiä myöhemmin järkevämpi keino, toistaseks tämä on close enough
$Salasana = "Salasana1"
$SalattuSalasana = $Salasana | ConvertTo-SecureString -AsPlainText -Force
Foreach($user in $users){
    $laskuri = $laskuri + 1
    Remove-ADUser $user.FirstName -confirm:$false
}
Write-Host "Scripti poisti " $laskuri "käyttäjää"