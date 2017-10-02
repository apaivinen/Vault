$email = 
$subject = "Test subject"
$body = "Test body"
 
$site = New-Object Microsoft.SharePoint.SPSite "www.sharepointcentraladmin.com"
$web = $site.OpenWeb()
[Microsoft.SharePoint.Utilities.SPUtility]::SendEmail($web,0,0,$email,$subject,$body)
