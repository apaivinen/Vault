#
#Raakaversio user profile syncistä profiilien lukumäärän hakuun sekä mahdolliseen syncissä ilmenneiden rikkinäisten profiilien määrän hakemiseen.
#
Write-host "******USER PROFILE SYNC******" -BackgroundColor Green -ForegroundColor black

	$site = new-object Microsoft.SharePoint.SPSite("http://wwwcm.keravanopisto.dev"); #Muuta ympäristön mukaan
    $ServiceContext = [Microsoft.SharePoint.SPServiceContext]::GetContext($site);  

    #Get UserProfileManager from the My Site Host Site context 
    $ProfileManager = new-object Microsoft.Office.Server.UserProfiles.UserProfileManager($ServiceContext)    
    $AllProfiles = $ProfileManager.GetEnumerator()  
    $i = 0;
    foreach($profile in $AllProfiles)  
    {  
        $DisplayName = $profile.DisplayName  
        $AccountName = $profile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::AccountName].Value  


        #Here goes writing Logic to your SharePoint List + Check if account already existing in the SharePoint list then ignore writing.......
        #write-host "Profile for account ", $AccountName 
        $i++;
        

    }  
	
write-host "User profiles: "$i
$ComputerName = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$hours = 24
$ServerName = $ComputerName
#write-host $ComputerName

function Get-SPSyncMA
{
[CmdletBinding()]
Param(
 [parameter(Mandatory=$true)][string]$ComputerName
)
Process
{
	Get-WmiObject -ComputerName $ComputerName -Class MIIS_ManagementAgent -Namespace root/MicrosoftIdentityIntegrationServer | Where {$_.Name -like "MOSS*"}
}
}
    
    
function Get-FimMARuns
{
 [CmdletBinding()]
Param(
	[parameter(Mandatory=$true)]
	[string]$MaName,
	[parameter(Mandatory=$true)]
	[string]$Hours,
	[parameter(Mandatory=$true)]
	[string]$ComputerName
)
Process
{
	$timeSpan = New-TimeSpan -Hours $Hours
	$nowUTC = (Get-Date).ToUniversalTime()
	$timeToStart = $nowUTC.Add(-$timeSpan)
	$filter = ("MaName = '{0}'" -F $MaName)
	$allHistory = Get-WmiObject -ComputerName $ComputerName -Class MIIS_RunHistory -Namespace root/MicrosoftIdentityIntegrationServer -Filter $filter
	ForEach ($history in $allHistory)
	{
		#Converting the start of the sync operation in order to be easier for comparing with the report interval
		$startTimeinDateTime = $history.RunStartTime | Get-Date
		if ($startTimeinDateTime -gt $timeToStart)
		{
			Write-Output $history
		}
	}
}
}

$faultyOperations =@()
$syncAgents = Get-SPSyncMA -ComputerName $ServerName
ForEach ($syncAgent in $syncAgents)
{
	$faultyOperations += Get-FimMARuns -MaName $syncAgent.Name -ComputerName $ServerName -Hours $Hours | Where {$_.RunStatus -ne 'success'}
}

$syncErrors

If($faultyOperations)
{

	ForEach ($faultyOp in $faultyOperations)
	{
		[xml]$asXML = $faultyOp.RunDetails().ReturnValue
		$connName = $asXML.'run-history'.'run-details'.'ma-name'
		$profile = $asXML.'run-history'.'run-details'.'run-profile-name'
		$start = $asXML.'run-history'.'run-details'.'step-details'.'start-date'
		$status = $faultyOp.RunStatus
		$syncErrors = ($asXML.'run-history'.'run-details'.'step-details'.'synchronization-errors'.GetEnumerator() | Measure-Object).Count
		$disErrors = ($asXML.'run-history'.'run-details'.'step-details'.'ma-discovery-counters'.GetEnumerator() | Measure-Object).Count
		$retErrors = ($asXML.'run-history'.'run-details'.'step-details'.'mv-retry-errors'.GetEnumerator() | Measure-Object).Count
        
	}

    write-host "Sync erros: "$syncErrors
}else{ write-host "No user profile sync errors"}
	
	
    write-host "******END OF USER PROFILE SYNC******" -BackgroundColor Green -ForegroundColor black
    #$site.Dispose() 


