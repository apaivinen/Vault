Add-PSSnapin "Microsoft.SharePoint.PowerShell" #rekisteröidään PSSnapin SP varte
$site = Get-SPSite "HTTPS:\\OSOITE..." #Määritetään SP:n osoite
$web = $site.RootWeb
$list = $web.Lists["tuotteet"]
$items = $list.Items
$items.count #count ja sen tulos on vain testausta ja kokonaisuuden hahmottamista
1265
$item = $items[2] 

foreach ($item in $list.Items){ 
	if ($item["ows_PhkkpLocation"] -eq "Lahden ammattikorkeakoulu, Muotoilu- ja taideinstituutti, Kannaksenkatu 22, 15140 Lahti")
		{$item["ows_PhkkpLocation"] = "Lahden ammattikorkeakoulu, Muotoiluinstituutti, Kannaksenkatu 22, 15140 Lahti";
		$item.Update();
		Write-Host $item.title + " Updated"  -f green}
} 