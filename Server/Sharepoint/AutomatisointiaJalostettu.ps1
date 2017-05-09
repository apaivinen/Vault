##tehty KUA ympäristöä käyttäen


## ERROR EVENTS
##20137 = The Sharepoint health Analyzer Detected a condition requiring your attention. Drives are at risk of running out of free space.

## WARNING EVENTS
## 20138 = The Sharepoint health Analyzer Detected a condition requiring your attention. Drives are at risk of running out of free space.
## 1314 = The start address ... central admin... cannot be crawled
$cpuusage1 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average

$errorevents = @(2137)

$warningevents = @(2138, 1314)

$GetNow = Get-date
$GetWeekAgo = (get-date).AddDays(-7)

$cpuusage2 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average

write-host ""
write-host "Warning events" -BackgroundColor Green
get-eventlog -LogName Application -Source "*sharepoint*" -EntryType error -After $GetWeekAgo -Before $GetNow | where-object{$errorevents -notcontains $_.EventID}
$cpuusage3 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
write-host ""
write-host "Error events" -BackgroundColor Green
get-eventlog -LogName Application -Source "*sharepoint*" -EntryType warning -After $GetWeekAgo -Before $GetNow | where-object{$warningevents -notcontains $_.EventID}

write-host ""
write-host "Hard disk information" -BackgroundColor Green

$cpuusage4 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
$disks = GET-WMIOBJECT -query "SELECT * from win32_logicaldisk where DriveType = 3"
Foreach($i in $disks){

	$freespace = [math]::Round($i.freespace / 1gb, 2)
	$totalsize = [math]::Round($i.size / 1gb, 2)
	$percent = [math]::Round($freespace * 100 / $totalsize, 2)

	write-host $i.deviceid $i.volumename $freespace "GB / "$totalsize "GB ---- "$percent"% of free space left"  
}


write-host ""
write-host "Memory usage" -BackgroundColor Green
$mem = Get-WmiObject -Class Win32_OperatingSystem | select TotalVirtualMemorySize,TotalVisibleMemorySize,FreePhysicalMemory,FreeVirtualMemory,FreeSpaceInPagingFiles
$memtotal = [math]::Round($mem.TotalVisibleMemorySize / 1mb, 2)
$memfree = [math]::Round($mem.FreePhysicalMemory / 1mb, 2)
$memused = $memtotal - $memfree
write-host "Muistia yhteensä: "$memtotal" gb"
write-host "Muistia jäljellä: "$memfree" gb" 
write-host  "Muistia käytössä: "$memused" gb"

write-host ""
write-host "CPU usage" -BackgroundColor Green

$cpuusage5 = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
$avgcpu = ($cpuusage1.average+$cpuusage2.average+$cpuusage3.average+$cpuusage4.average+$cpuusage5.average)/5
write-host $avgcpu" %"