if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

<#
Developed by using SP2013 on local virtual machine. And X SP2010 test environment

Run this script and copy & paste rows from the powershell window to $ignored  which you want to ignore in the future

If you want to have complete results from healthanalyzer with all the details Comment $result line and uncomment #$xml in the end
#>

$ignored = @(
	"Databases exist on servers running SharePoint Foundation.",
	"Drives are at risk of running out of free space.",
	"Missing server side dependencies.",
	"Accounts used by application pools or service identities are in the local machine Administrators group."
)

$centraladmin = Get-spwebapplication -includecentraladministration | where {$_.IsAdministrationWebApplication}
$centralAdminURL = $centraladmin.url
$listName = "Review Problems and Solutions"
$spSourceWeb = Get-SPWeb $centralAdminURL
$spSourceList = $spSourceWeb.Lists[$listName]

$xml = $spSourceList.Items | Where-Object {$_['Severity'] -ne '4 - Success'} | ForEach-Object {

    New-Object PSObject -Property @{
        Title = $_['Title']
#	Title = "$FormUrl$($_.ID)'>$($_['Title'])"
        Severity = $_['Severity']
        Category = $_['Category']
        Explanation = $_['Explanation']
        Modified = $_['Modified']
        FailingServers = $_['Failing Servers']
        FailingServices = $_['Failing Services']
        Remedy = $_['Remedy']
    }
 }

write-host "Sharepoint Health Analyzer" -BackgroundColor Green -ForegroundColor black

$result=@()
foreach($node in $xml){
	$result +=$node.title
}

$result | where {$ignored -notcontains $_}

#$xml

write-host "End of Sharepoint Health Analyzer" -BackgroundColor Green -ForegroundColor black