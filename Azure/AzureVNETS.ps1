New-AzureRmResourceGroup -Name MyRG -Location NorthEurope

New-AzureRmVirtualNetwork -ResourceGroupName MyRG -Name MyVNet -AddressPrefix 192.168.0.0/16 -Location NorthEurope

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName MyRG -Name MyVNet

Add-AzureRmVirtualNetwork -ResourceGroupName MyRG -Name MyVNet

Add-AzureRmVirtualNetworkSubnetConfig -Name FESubnet -VirtualNetwork $vnet -AddressPrefix 192.168.1.0/24

Add-AzureRmVirtualNetworkSubnetConfig -Name BESubnet -VirtualNetwork $vnet -AddressPrefix 192.168.2.0/24

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet