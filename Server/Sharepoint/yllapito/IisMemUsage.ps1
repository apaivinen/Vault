$ServerName = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$IisMemUsage = [Math]::Round( (Get-WMIObject -ComputerName $ServerName Win32_Process -Filter "Name='w3wp.exe'" | Measure-Object -Property "PrivatePageCount" -Sum).Sum/1Gb,2).ToString() + " Gt"
write-host "IIS Memory usage: "$IisMemUsage "`n"