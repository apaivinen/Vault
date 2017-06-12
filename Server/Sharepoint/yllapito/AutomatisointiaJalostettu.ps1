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
$cpuusage1 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average

$errorevents = @(2137, 1136)

$warningevents = @(2138, 1314, 1110)

$GetNow = Get-date
$GetWeekAgo = (get-date).AddDays(-7)

$cpuusage2 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average

write-host ""
write-host "Warning events" -BackgroundColor Green -ForegroundColor black
get-eventlog -LogName Application -Source "*sharepoint*" -EntryType error -After $GetWeekAgo -Before $GetNow | where-object{$errorevents -notcontains $_.EventID}
$cpuusage3 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
write-host ""
write-host "Error events" -BackgroundColor Green -ForegroundColor black
get-eventlog -LogName Application -Source "*sharepoint*" -EntryType warning -After $GetWeekAgo -Before $GetNow | where-object{$warningevents -notcontains $_.EventID}

write-host ""
write-host "Hard disk information" -BackgroundColor Green -ForegroundColor black

$cpuusage4 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
$disks = GET-WMIOBJECT -query "SELECT * from win32_logicaldisk where DriveType = 3"
Foreach($i in $disks){

	$freespace = [math]::Round($i.freespace / 1gb, 2)
	$totalsize = [math]::Round($i.size / 1gb, 2)
	$percent = [math]::Round($freespace * 100 / $totalsize, 2)

	write-host $i.deviceid $i.volumename $freespace "GB / "$totalsize "GB ---- "$percent"% of free space left"  
}


write-host ""
write-host "Memory usage" -BackgroundColor Green -ForegroundColor black
$mem = Get-WmiObject -Class Win32_OperatingSystem | select TotalVirtualMemorySize,TotalVisibleMemorySize,FreePhysicalMemory,FreeVirtualMemory,FreeSpaceInPagingFiles
$memtotal = [math]::Round($mem.TotalVisibleMemorySize / 1mb, 2)
$memfree = [math]::Round($mem.FreePhysicalMemory / 1mb, 2)
$memused = $memtotal - $memfree
$mempercent = [math]::Round($memfree * 100 / $memtotal, 2)
write-host "Muistia yhteensä: "$memtotal" gb"
write-host "Muistia jäljellä: "$memfree" gb"
write-host  "Muistia käytössä: "$memused" gb  ---- " $mempercent "% of memory in use"

write-host "VIRTUAL MEMORY" -BackgroundColor Green -ForegroundColor black

$vmemtotal = [math]::Round($mem.TotalVirtualMemorySize / 1mb, 2)
$vmemfree = [math]::Round($mem.FreeVirtualMemory / 1mb, 2)
$vmemused = $vmemtotal - $vmemfree
$vmempercent = [math]::Round($vmemfree * 100 / $vmemtotal, 2)

write-host "Muistia yhteensä: "$vmemtotal" gb"
write-host "Muistia jäljellä: "$vmemfree" gb" 
write-host  "Muistia käytössä: "$vmemused" gb  ---- " $vmempercent "% of memory in use"




write-host ""
write-host "CPU usage" -BackgroundColor Green -ForegroundColor black

$cpuusage5 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
$avgcpu = ($cpuusage1.average+$cpuusage2.average+$cpuusage3.average+$cpuusage4.average+$cpuusage5.average)/5
write-host $avgcpu" %"


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




