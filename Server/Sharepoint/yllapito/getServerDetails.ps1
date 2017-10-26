<#
Gets information about current computer. 
Name
CPU usage
Hard disk information
Memory usage, physical memory, physical+virtual memory and IIS memory usage.

#>

$computer = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
write-host "Server name: " $computer

$CPU  = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -average | select average
write-host "CPU Usage: " $cpu.average"%"
write-host "Hard disk information:" -BackgroundColor Green -ForegroundColor black
$disks = GET-WMIOBJECT -query "SELECT * from win32_logicaldisk where DriveType = 3"
Foreach($i in $disks){

	$freespace = [math]::Round($i.freespace / 1gb, 2)
	$totalsize = [math]::Round($i.size / 1gb, 2)
	$spaceused = $totalsize - $freespace
	$percent = [math]::Round($spaceused * 100 / $totalsize, 2)

	write-host $i.deviceid $i.volumename $freespace "GB / "$totalsize "GB ---- "$percent"% of free space left"  
}#end of Foreach

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