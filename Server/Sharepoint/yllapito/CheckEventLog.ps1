<#
Different times for filthering events:
Change number value of "timediff((@SystemTime) &lt;= 604800000"
1h = 3600000
12h = 43200000
24h = 86400000
7d = 604800000
30d = 2592000000

How to ignore specific event ID:

Add "EventID=IDNumber or" to  $ignoredEvents variable. 
The last EventID=IDNumber can't have OR at the end of it!


List of ignored events:
2138	The SharePoint Health Analyzer detected a condition requiring your attention.  Drives are at risk of running out of free space.
1136	 The evaluation period for this instance of Microsoft SQL Server Reporting Services has expired.  A license is now required. (Application: Reporting Service, CorrelationId: 00000000-0000-0000-0000-000000000000)
1314 	 The start address sps3://kuasp:8080 cannot be crawled. Context: Application 'SSA', Catalog 'Portal_Content'

#>
$ignoredEvents = '

    EventID=2138 or
	EventID=1136 or
	EventID=1314

'






$queryCriticals = '<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=1) and TimeCreated[timediff(@SystemTime) &lt;= 604800000]]]</Select>

    <Suppress Path="Application">*[System[(
    '+
    $ignoredEvents+
    '
    )]]</Suppress>
  </Query>
</QueryList>';


$queryErrors = '<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=2) and TimeCreated[timediff(@SystemTime) &lt;= 604800000]]]</Select>

    <Suppress Path="Application">*[System[(
    '+
    $ignoredEvents+
    '
    )]]</Suppress>
  </Query>
</QueryList>';


$queryWarnings = '<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 604800000]]]</Select>

    <Suppress Path="Application">*[System[(
    '+
    $ignoredEvents+
    '
    )]]</Suppress>
  </Query>
</QueryList>';





function List-Events{
    param($uniqueid,$lista)
    $i=0
    $Message = ""   
    $category = 0 

    Foreach($id in $uniqueid){#Get all unique ID
        foreach($item in $lista){#Get all events and get count of the same events.
            if($id -eq $item.id){
                $i++
                $Message = $item.Message
                $category = $item.Level
            }#end of if
        }#end of foreach

        switch($category){
            0 {write-host "Category: No value?" }
            1 {write-host "Category: Critical" -BackgroundColor "red" -foregroundcolor "black"}
            2 {write-host "Category: Error" -BackgroundColor "yellow" -foregroundcolor "black"}
            3 {write-host "Category: Warning" -BackgroundColor "Gray" -foregroundcolor "black"}

        }#End of Switch

        write-host "EVENT ID:" $id
        write-host "COUNT: " $i " times" -BackgroundColor "black" -foregroundcolor "red"
        write-host "MESSAGE:`n" $Message 
        write-host ""
        $Message = ""
        $category = 0 
        $i=0
    }#End of ForEach
}#End of List-Events function

#Check critical events
write-host ""
write-host "******************************" -ForegroundColor "green"
Write-host "CHECKING CRITICAL EVENTS"-ForegroundColor "green"
write-host "******************************"-ForegroundColor "green"
write-host ""
$events = Get-WinEvent -FilterXml $queryCriticals
$eventsUniqueID = $events.id | select -uniq
List-Events $eventsUniqueID $events

#Check error events
write-host ""
write-host "******************************"-ForegroundColor "green"
Write-host "CHECKING ERROR EVENTS"-ForegroundColor "green"
write-host "******************************"-ForegroundColor "green"
write-host ""
$events = Get-WinEvent -FilterXml $queryErrors
$eventsUniqueID = $events.id | select -uniq
List-Events $eventsUniqueID $events 

#Check warning events
write-host ""
write-host "******************************"-ForegroundColor "green"
Write-host "CHECKING WARNING EVENTS"-ForegroundColor "green"
write-host "******************************"-ForegroundColor "green"
write-host ""
$events = Get-WinEvent -FilterXml $queryWarnings
$eventsUniqueID = $events.id | select -uniq
List-Events $eventsUniqueID $events 

write-host ""
write-host "******************************"-ForegroundColor "green"
Write-host "THE END"-ForegroundColor "green"
