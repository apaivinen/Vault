##tehty KUA ympäristöä käyttäen

## Event ID filter lista kokonaisuudessaan
## -2137, -2138, -1314, -1110, -1136

## ERROR EVENTS
##20137 = The Sharepoint health Analyzer Detected a condition requiring your attention. Drives are at risk of running out of free space.
##1136 = The evaluation perioid for this instance of MS SQL Server reporting services has expired. A license is now required

## WARNING EVENTS
## 20138 = The Sharepoint health Analyzer Detected a condition requiring your attention. Drives are at risk of running out of free space.
## 1314 = The start address ... central admin... cannot be crawled
## 1110 = The value for UrlRoot in rsreportserver.config is not valid. The default will be used instead

function GetPerformance(){
	$CPU  = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
}

$computer = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name

$cpuusage1 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average

$errorevents = @(2137, 1136)

$warningevents = @(2138, 1314, 1110)

$GetNow = Get-date
$GetWeekAgo = (get-date).AddDays(-7)

$cpuusage2 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average

write-host "Critical events"
$CriticalEventList = Get-WinEvent -FilterHashtable @{logname='application'; level=1; StartTime=$GetWeekAgo; EndTime=$GetNow}


write-host ""
write-host "Error events" -BackgroundColor Green -ForegroundColor black
get-eventlog -LogName Application -Source "*sharepoint*" -EntryType error -After $GetWeekAgo -Before $GetNow | where-object{$errorevents -notcontains $_.EventID}
$cpuusage3 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
write-host ""
write-host "Warning events" -BackgroundColor Green -ForegroundColor black
get-eventlog -LogName Application -Source "*sharepoint*" -EntryType warning -After $GetWeekAgo -Before $GetNow | where-object{$warningevents -notcontains $_.EventID}

write-host ""
write-host "Hard disk information" -BackgroundColor Green -ForegroundColor black

$cpuusage4 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
$disks = GET-WMIOBJECT -query "SELECT * from win32_logicaldisk where DriveType = 3"
Foreach($i in $disks){

	$freespace = [math]::Round($i.freespace / 1gb, 2)
	$totalsize = [math]::Round($i.size / 1gb, 2)
	$spaceused = $totalsize - $freespace
	$percent = [math]::Round($spaceused * 100 / $totalsize, 2)

	write-host $i.deviceid $i.volumename $freespace "GB / "$totalsize "GB ---- "$percent"% of free space left"  
}#end of Foreach


write-host ""
write-host "Physical memory usage" -BackgroundColor Green -ForegroundColor black
$mem = Get-WmiObject -Class Win32_OperatingSystem | select TotalVirtualMemorySize,TotalVisibleMemorySize,FreePhysicalMemory,FreeVirtualMemory,FreeSpaceInPagingFiles
$memtotal = [math]::Round($mem.TotalVisibleMemorySize / 1mb, 2)
$memfree = [math]::Round($mem.FreePhysicalMemory / 1mb, 2)
$memused = $memtotal - $memfree
$mempercent = [math]::Round($memused * 100 / $memtotal, 2)
write-host "Physical memory in total: "$memtotal" gb"
write-host "Physical memory left: "$memfree" gb"
write-host  "Physical memory in use: "$memused" gb  ---- " $mempercent "% of memory in use"

write-host "Virtual memory usage" -BackgroundColor Green -ForegroundColor "black"

$vmemtotal = [math]::Round($mem.TotalVirtualMemorySize / 1mb, 2)
$vmemfree = [math]::Round($mem.FreeVirtualMemory / 1mb, 2)
$vmemused = $vmemtotal - $vmemfree
$vmempercent = [math]::Round($vmemused * 100 / $vmemtotal, 2)

write-host "Virtual memory in total: "$vmemtotal" gb"
write-host "Virtual memory left: "$vmemfree" gb" 
write-host  "Virtual memory in use: "$vmemused" gb  ---- " $vmempercent "% of memory in use"


$IisMemUsage = [Math]::Round( (Get-WMIObject -ComputerName $computer Win32_Process -Filter "Name='w3wp.exe'" | Measure-Object -Property "PrivatePageCount" -Sum).Sum/1Gb,2).ToString() + " Gt"
Write-host "IIS memory usage" -BackgroundColor Green -ForegroundColor "black"
write-host $IisMemUsage

write-host ""
write-host "CPU usage" -BackgroundColor Green -ForegroundColor "black"

$cpuusage5 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
$avgcpu = ($cpuusage1.average+$cpuusage2.average+$cpuusage3.average+$cpuusage4.average+$cpuusage5.average)/5
write-host $avgcpu" %"

#
#
#Sharepoint section -> 
#
#

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}


$centraladmin = Get-spwebapplication -includecentraladministration | where {$_.IsAdministrationWebApplication}
$centralAdminURL = $centraladmin.url
$listName = "Review Problems and Solutions"
$spSourceWeb = Get-SPWeb $centralAdminURL
$spSourceList = $spSourceWeb.Lists[$listName]

$xml = $spSourceList.Items | Where-Object {$_['Severity'] -ne '4 - Success'} | ForEach-Object {

    New-Object PSObject -Property @{
        STARTOFITEM = "*******************************************************************"
        Title = "$FormUrl$($_.ID)'>$($_['Title'])"
        Severity = $_['Severity']
        Category = $_['Category']
        Explanation = $_['Explanation']
        Modified = $_['Modified']
        FailingServers = $_['Failing Servers']
        FailingServices = $_['Failing Services']
        Remedy = $_['Remedy']
        ENDOFITEM = "*******************************************************************"
    }
 
 }

write-host ""
write-host "Sharepoint Health Analyzer" -BackgroundColor Green -ForegroundColor black
$xml

#
#Sharepoint User Profile sync check
#Checks total number of user profiles and user profile errors
#

$site = new-object Microsoft.SharePoint.SPSite("http://wwwcm.keravanopisto.dev");  
$ServiceContext = [Microsoft.SharePoint.SPServiceContext]::GetContext($site);  

#Get UserProfileManager from the My Site Host Site context 
$ProfileManager = new-object Microsoft.Office.Server.UserProfiles.UserProfileManager($ServiceContext)    
$AllProfiles = $ProfileManager.GetEnumerator()  
$i = 0;
foreach($profile in $AllProfiles){  
	$DisplayName = $profile.DisplayName  
    $AccountName = $profile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::AccountName].Value  
    $i++;   
}#end of ForEach  
Write-host "******USER PROFILE SYNC******" -BackgroundColor "green" -ForegroundColor "black"
write-host "User profiles: "$i	

$hours = 24
$ServerName = $computer

function Get-SPSyncMA{
	[CmdletBinding()]
	Param(
	[parameter(Mandatory=$true)][string]$computer
	)
	Process{
		Get-WmiObject -computer $computer -Class MIIS_ManagementAgent -Namespace root/MicrosoftIdentityIntegrationServer | Where {$_.Name -like "MOSS*"}
	}
}#end of function Get-SPSyncMA
    
    
function Get-FimMARuns
{
	[CmdletBinding()]
	Param(
		[parameter(Mandatory=$true)]
		[string]$MaName,
		[parameter(Mandatory=$true)]
		[string]$Hours,
		[parameter(Mandatory=$true)]
		[string]$computer
	)
	Process{
		$timeSpan = New-TimeSpan -Hours $Hours
		$nowUTC = (Get-Date).ToUniversalTime()
		$timeToStart = $nowUTC.Add(-$timeSpan)
		$filter = ("MaName = '{0}'" -F $MaName)
		$allHistory = Get-WmiObject -computer $computer -Class MIIS_RunHistory -Namespace root/MicrosoftIdentityIntegrationServer -Filter $filter
		ForEach ($history in $allHistory)
		{
			#Converting the start of the sync operation in order to be easier for comparing with the report interval
			$startTimeinDateTime = $history.RunStartTime | Get-Date
			if ($startTimeinDateTime -gt $timeToStart)
			{
				Write-Output $history
			}#End of If
		}#End of ForEach
	}
}#end of Function Get-FimMARuns

$faultyOperations =@()
$syncAgents = Get-SPSyncMA -computer $ServerName
ForEach ($syncAgent in $syncAgents){
	$faultyOperations += Get-FimMARuns -MaName $syncAgent.Name -computer $ServerName -Hours $Hours | Where {$_.RunStatus -ne 'success'}
}#end of ForEach

$syncErrors

If($faultyOperations)
{

	ForEach ($faultyOp in $faultyOperations){
		[xml]$asXML = $faultyOp.RunDetails().ReturnValue
		$connName = $asXML.'run-history'.'run-details'.'ma-name'
		$profile = $asXML.'run-history'.'run-details'.'run-profile-name'
		$start = $asXML.'run-history'.'run-details'.'step-details'.'start-date'
		$status = $faultyOp.RunStatus
		$syncErrors = ($asXML.'run-history'.'run-details'.'step-details'.'synchronization-errors'.GetEnumerator() | Measure-Object).Count
		$disErrors = ($asXML.'run-history'.'run-details'.'step-details'.'ma-discovery-counters'.GetEnumerator() | Measure-Object).Count
		$retErrors = ($asXML.'run-history'.'run-details'.'step-details'.'mv-retry-errors'.GetEnumerator() | Measure-Object).Count
        
	}#end of ForEach
    write-host "Sync erros: "$syncErrors -ForegroundColor "magenta"
	}#end of If
	else{ 
		write-host "No user profile sync errors" -ForegroundColor "DarkGreen"
	}#end of else
	
	
write-host "******END OF USER PROFILE SYNC******`n" -BackgroundColor "green" -ForegroundColor "black"

$site.Dispose() 


#
#Windows update check
#Check available updates (Criticals, importants, optionals)
#

write-host "*************Windows update check***********" -BackgroundColor "green" -ForegroundColor "black"
$updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$computer)) 

Write-host "Creating COM object for WSUS update Search" 
$updatesearcher = $updatesession.CreateUpdateSearcher() 

                Write-host "Searching for WSUS updates on client" 
				write-host "This may take a while."
                $searchresult = $updatesearcher.Search("IsInstalled=0") 
		
                #Verify if Updates need installed 
                Write-host "Verifing that updates are available to install" 
                If ($searchresult.Updates.Count -gt 0) { 
                    #Updates are waiting to be installed 
                    Write-host "Found $($searchresult.Updates.Count) update\s!" 
                    #Cache the count to make the For loop run faster 
                    $count = $searchresult.Updates.Count 
					$OptionalUpdates = 0
					$CriticalUpdates = 0
					$ImportantUpdates = 0

                    Write-host "Iterating through list of updates" 
                    For ($i=0; $i -lt $Count; $i++) { 
                        $Update = $searchresult.Updates.Item($i)
						
						if($Update.MsrcSeverity -eq 'Critical')
						{ 		
							$CriticalUpdates++;
						}
						if($Update.MsrcSeverity -eq 'Important')
						{ 
							$ImportantUpdates++ ;
						}if($Update.MsrcSeverity -le '')
						{
							$OptionalUpdates++;
						}else{}
						
                    }
					write-host "Critical updates count = " $criticalupdates
					write-host "Important updates count = " $ImportantUpdates
					write-host "Optional updates count = " $optionalupdates
					write-host $count " updates in total."
                } 
                Else { 
                    #Nothing to install at this time 
                    Write-host "No updates to install." 
                }
Write-host "End of script." -BackgroundColor "green" -ForegroundColor "black"
Write-host "End of script." -BackgroundColor "green" -ForegroundColor "black"
Write-host "End of script." -BackgroundColor "green" -ForegroundColor "black"