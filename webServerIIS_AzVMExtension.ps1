$resourceGroupName = "rs_3"
$location = "CanadaCentral"
$vmName = "webServer"
$vmSize = "Standard_DS1_v2"

# Create a new resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Create Virtual Network and Subnet
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "$($vmName)VNet" -AddressPrefix "10.0.0.0/16"
$subnetConfig = Add-AzureRmVirtualNetworkSubnetConfig -Name "default" -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet
$vnet = Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
$subnetId = $vnet.Subnets[0].Id

# Create Public IP Address with Static Allocation
$publicIp = New-AzureRmPublicIpAddress -Name "$($vmName)PublicIP" -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static -Sku Standard

# Create Network Security Group and open port 80
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name 'RDP' -Description 'Allow RDP' -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix Internet -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 3389
$nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name 'Web' -Description 'Allow HTTP' -Access Allow -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix Internet -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 80
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "$($vmName)NSG" -SecurityRules $nsgRuleRDP,$nsgRuleWeb

# Create Network Interface with the Public IP Address and associate with NSG
$nic = New-AzureRmNetworkInterface -Name "$($vmName)NIC" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnetId -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Create VM Configuration
$cred = Get-Credential -Message "Enter a username and password for the VM."

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize | 
    Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate |
    Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" |
    Add-AzureRmVMNetworkInterface -Id $nic.Id

# Create the VM
New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Install IIS and update index.html
$customScript = @"
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Start-Sleep -s 10
\$content = $vmName
Set-Content -Path 'C:\inetpub\wwwroot\index.html' -Value \$content
"@

$encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($customScript))

Set-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name "SetupIIS" -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.4" -Location $location -Settings @{"commandToExecute" = "powershell -EncodedCommand $encodedScript"}

