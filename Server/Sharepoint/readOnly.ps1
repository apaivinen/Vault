<#
MUUTA PATH TARVITTAESSA!
#>
$path = "c:\temp\readonly.csv"
$sivut = Import-Csv -Delimiter '|' -Path $path

Foreach($sivu in $sivut){
    Set-SPSite -Identity $sivu.url -LockState "ReadOnly"
    write-host $sivu.url
}