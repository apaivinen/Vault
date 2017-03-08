$Manager = Get-ADUser admin

Get-ADUser -Filter { manager -eq $Manager.DistinguishedName }