
##############################################################
########## Toimii ainakin SP 2013 ############################
##############################################################
#EI ota huomioon alikansioita @ $localFolderPath

$webUrl = "http://www.sivusto.epic/test/"

$docLibraryName = "Kuvapankki"
$docLibraryUrlName = "/test/kuvapankki/"
$localFolderPath = "C:\temp\kirjasto"

#Open web and library
$web = Get-SPWeb $webUrl
$docLibrary = $web.Lists[$docLibraryName]
$files = ([System.IO.DirectoryInfo] (Get-Item $localFolderPath)).GetFiles()
ForEach($file in $files)
{
	#Open file
	$fileStream = ([System.IO.FileInfo] (Get-Item $file.FullName)).OpenRead()
	write-host $file
	#Add file
	$folder =  $web.getfolder($docLibraryUrlName)

	write-host "Copying file " $file.Name " to " $folder.ServerRelativeUrl "..."
	$spFile = $folder.Files.Add($folder.Url + "/" + $file.Name, [System.IO.Stream]$fileStream, $true)
	write-host "Success"

	#Close filestream
	$fileStream.Close();
}


$web.Dispose()