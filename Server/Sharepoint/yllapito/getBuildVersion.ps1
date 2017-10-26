if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

$farm = Get-SPFarm
$farm.BuildVersion