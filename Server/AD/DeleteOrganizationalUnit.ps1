#Hakee tytöt OU:N AD:sta, poistaa siitä protected from accidental deletionin ja poistaa Tytöt OU:n
Get-ADOrganizationalUnit -Identity 'OU=tytöt,DC=anssi,DC=local' | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Confirm:$false