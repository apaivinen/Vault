#hakee käyttäjät jonka manager on admin
$Manager = Get-ADUser admin
Get-ADUser -Filter { manager -eq $Manager.DistinguishedName }

#hakee kaikki käyttäjät organisaatio yksiköstä ja sen aliyksiköistä
Get-ADUser -filter * -SearchBase "ou=kiosk,dc=anssi,dc=local" -SearchScope Subtree

#hakee kaikki käyttäjän propertyt
$user = "admin"
Get-ADUser -Identity $user -Properties *

#Hae kaikki käyttäjät jotka ovat kirjautuneet 7.3.2017 jälkeen, -lt on ennen, -eq jne
Get-ADUser -Filter {lastlogondate -gt "march 7, 2017"}

#Hae kaikki käyttäjät jotka ovat kirjautuneet 7.3.2017 jälkeen osastosta ...
Get-ADUser -Filter {lastlogondate -gt "march 7, 2017" -and (department -eq "Goddess")}
#voidaan putkittaa loppuun esim.  |Disable-ADAccount jolloin kriteereihin sopivat tunnukset sulkeutuu

#hae UAC arvot nimistä jotka alkavat "Ta*"
Get-ADUser -Filter {sn -like "Ta*"} -Properties userAccountControl|Select Name, userAccountControl|FT –AutoSize 

#hae kaikki disabled accountit
Search-ADAccount -AccountDisabled | Select name 

#hae kaikki accountit jotka expiree 7.4.2017
Search-ADAccount -AccountExpiring -DateTime "4/7/2017" -UsersOnly 

#Hae kaikki lukitut tietokoneet
Search-ADAccount -ComputersOnly -LockedOut



#PUTKITUS ESIMERKKI hae kaikki jolla on tyhjä company ja aseta niille companyksi "EI"
# Get-ADUser -Filter {company -notLike "*"} | Set-ADUser -Company "EI" 