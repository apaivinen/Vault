Login-AzureRmAccount
Get-AzureRmSubscription
$AzureSubscriptionId = read-Host -Prompt "Enter Azure Subscription ID"

Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId

$myResourceGroup = Read-Host -Prompt "Enter Resource Group Name"
$myStorageAccountName = Read-Host -Prompt "Enter Storage Account name"
$VMName = Read-Host -Prompt "Enter Virtual machine name"
$adminName = read-host -Prompt "Enter admin username"
$adminPass = read-host -Prompt "Enter admin password" -AsSecureString


#North Europe
$location = "northeurope"

#VM Basic koot : Standard_A0 - Standard_A7"
#VM Compute koot : Standard_A8 - Standard_A11"
$VMSize = "Standard_A0"

$StorageSkuName = "Standard_LRS"

#kind = Storage TAI BlobStorage
$storageKind = "Storage" 

New-AzureRmResourceGroup -Name $myResourceGroup -Location $location

Write-Host "Resurssiryhmä " $myResourceGroup " sijaintiin " $location "luotu"
 
Get-AzureRmStorageAccountNameAvailability $myStorageAccountName

$myStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $myResourceGroup -Name $myStorageAccountName -SkuName $StorageSkuName -Kind $storageKind -Location $location

write-host "Storage account " $myStorageAccountName " luotu"
write-host "parametrit:"
write-host "resurssiryhmä= " $myResourceGroup
write-host "SKU= "$StorageSkuName
write-host "Kind=  " 
write-host "Location= " $location

$mySubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "mySubnet" -AddressPrefix 10.0.0.0/24

$myVnet = New-AzureRmVirtualNetwork -Name "myVnet" -ResourceGroupName $myResourceGroup -Location $location -AddressPrefix 10.0.0.0/16 -Subnet $mySubnet

#public ip
$myPublicIp = New-AzureRmPublicIpAddress -Name "myPublicIp" -ResourceGroupName $myResourceGroup -Location $location -AllocationMethod Dynamic

$myNIC = New-AzureRmNetworkInterface -Name "myNIC" -ResourceGroupName $myResourceGroup -Location $location -SubnetId $myVnet.Subnets[0].Id -PublicIpAddressId $myPublicIp.Id

write-host "VNET: myVnet, AddressPrefix 10.0.0.0/16"
write-host "Public IP: myPublicIP"
write-host "NIC: myNic"
Write-host "nämä ovat kovakoodattuja, muokkaa myöhemmin"

write-host " "
write-host "Aloitetaan virtuaalikoneen luonti"
$cred = New-Object System.Management.Automation.PSCredential ($adminName, $adminPass); 

$myVm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

$myVM = Set-AzureRmVMOperatingSystem -VM $myVM -Windows -ComputerName $VMName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$myVM = Set-AzureRmVMSourceImage -VM $myVM -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"

$myVM = Add-AzureRmVMNetworkInterface -VM $myVM -Id $myNIC.Id

$blobPath = "vhds/myOsDisk1.vhd"
$osDiskUri = $myStorageAccount.PrimaryEndpoints.Blob.ToString() + $blobPath

$myVM = Set-AzureRmVMOSDisk -VM $myVM -Name "myOsDisk1" -VhdUri $osDiskUri -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $myResourceGroup -Location $location -VM $myVM

Write-host "Virtuaaliokne nimeltä " $VMName " on luotu, kirjaudu sisään tunnuksella " $VMName"/"$adminName