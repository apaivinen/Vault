#pause
#region
#Location
#--------
#australiaeast
#australiasoutheast
#brazilsouth
#canadacentral
#canadaeast
#centralus
#eastasia
#eastus
#eastus2
#japaneast
#japanwest
#northcentralus
#northeurope HUOM TÄÄ EI TOIMI INNOFACTOR TUNNUKSELLA koska rajoittunut visual studio benefit
#southcentralus
#southeastasia
#uksouth
#ukwest
#westcentralus
#westeurope
#westus
#westus2
#endregion

#region TUHOA RG resurssiryhma

#Remove-AzureRmResourceGroup -name $myResourceGroup -Force

#endregion


#region Login
$cred = Get-Credential
Login-AzureRmAccount -Credential $cred
$subid = Get-AzureRmSubscription 
Select-AzureRmSubscription -SubscriptionId $subid
#endregion

#region Muuttujat
$location = "westeurope"
$myResourceGroup = "leikkikentta"
$myStorageAccountName ="leikkikentta20170116"
$AvailabilitySet = "DomainAvSet"
$ServerName = "AnssiDC"
#endregion

New-AzureRmResourceGroup -Name $myResourceGroup -Location $location


#region Storage accountin luonti 
Get-AzureRmStorageAccountNameAvailability $myStorageAccountName

$myStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $myResourceGroup -Name $myStorageAccountName -SkuName "Standard_LRS" -Kind "Storage" -Location $location
#endregion

#region LUODAAN AVAILABILITYSET

$AVSET = New-AzureRmAvailabilitySet -ResourceGroupName $myResourceGroup -Name $AvailabilitySet -Location $location -PlatformUpdateDomainCount 2 -PlatformFaultDomainCount 2

#endregion


#region VNET

$mySubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "subnet1" -AddressPrefix 10.0.0.0/24
$myVnet = New-AzureRmVirtualNetwork -Name "vnet" -ResourceGroupName $myResourceGroup -Location $location -AddressPrefix 10.0.0.0/16 -Subnet $mySubnet
#endregion

#region Public IP & NIC
$myPublicIp = New-AzureRmPublicIpAddress -Name "PublicIp" -ResourceGroupName $myResourceGroup -Location $location -AllocationMethod Dynamic
$myNIC = New-AzureRmNetworkInterface -Name "NIC1" -ResourceGroupName $myResourceGroup -Location $location -SubnetId $myVnet.Subnets[0].Id -PublicIpAddressId $myPublicIp.Id
#endregion

#Image publisherName
#Get-AzureRmVMImagePublisher -location "west europe" | select PublisherName | where {$_.PublisherName -like "*microsoft*"}
#
#
#Image SKU
#Get-AzureRmVMImageSku -Location "West europe" -PublisherName "MicrosoftWindowsServer" -offer "WindowsServer" | select Skus

#region Virtuaalikoneen luonti

$AdminCred = Get-Credential -Message "Type the name and password of the local administrator account."

$myVm = New-AzureRmVMConfig -VMName $ServerName -VMSize "Standard_DS1_v2" -AvailabilitySetId $AVSET.Id

$myVM = Set-AzureRmVMOperatingSystem -VM $myVM -Windows -ComputerName "myVM" -Credential $AdminCred -ProvisionVMAgent -EnableAutoUpdate

$myVM = Set-AzureRmVMSourceImage -VM $myVM -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "latest"

$myVM = Add-AzureRmVMNetworkInterface -VM $myVM -Id $myNIC.Id

$blobPath = "vhds/myOsDisk1.vhd"
$osDiskUri = $myStorageAccount.PrimaryEndpoints.Blob.ToString() + $blobPath

$myVM = Set-AzureRmVMOSDisk -VM $myVM -Name "myOsDisk1" -VhdUri $osDiskUri -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $myResourceGroup -Location $location -VM $myVM

#Get-AzureRMVM -ServiceName "<VmCloudServiceName>" -Name $ServerName | Set-AzureAvailabilitySet -AvailabilitySetName $AvailabilitySet | Update-AzureVM

#endregion