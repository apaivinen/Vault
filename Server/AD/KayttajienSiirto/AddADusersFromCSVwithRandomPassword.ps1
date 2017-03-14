$users=Import-CSV –LiteralPath “C:\users.csv” #CSV-file which contains users
$count = 0  
$errorcount = 0
$OUpath = "OU=userss,DC=azure2,DC=local"

Function MakeUp-String([Int]$Size = 8, [Char[]]$CharSets = "ULNS", [Char[]]$Exclude) {
    $Chars = @(); $TokenSet = @()
    If (!$TokenSets) {$Global:TokenSets = @{
        U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                #Upper case
        L = [Char[]]'abcdefghijklmnopqrstuvwxyz'                                #Lower case
        N = [Char[]]'0123456789'                                                #Numerals
        S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'                         #Symbols
    }}
    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach {If ($Exclude -cNotContains $_) {$_}}
        If ($Tokens) {
            $TokensSet += $Tokens
            If ($_ -cle [Char]"Z") {$Chars += $Tokens | Get-Random}             #Character sets defined in upper case are mandatory
        }
    }
    While ($Chars.Count -lt $Size) {$Chars += $TokensSet | Get-Random}
    ($Chars | Sort-Object {Get-Random}) -Join ""                                #Mix the (mandatory) characters and output string
}; Set-Alias Create-Password MakeUp-String -Description "Generate a random string (password)"


Add-content c:\accounts.txt "UPN,Password"

foreach ($user in $users){
    try{
    $GivenName = $user.GivenName
    $Surname = $user.Surname
    $UPN = $user.UserPrincipalName
    $Password = Create-Password 12 ULN 
    $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force    
    New-ADUser $givenName -GivenName $GivenName -Surname $Surname -AccountPassword $SecurePassword -ChangePasswordAtLogon $true -Enabled $true -Path $OUpath
    Add-content c:\accounts.txt $UPN","$Password
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

