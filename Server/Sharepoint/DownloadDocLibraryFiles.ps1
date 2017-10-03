$destination = "C:\path\to\folder\with\files"
$webUrl = "https://full.url.com/sivusto/test/"
$listUrl = "https://full.url.com/sivusto/test/tiedostokirjasto"

##############################################################
########## Toimii ainakin SP 2010 ############################
##############################################################

$web = Get-SPWeb -Identity $webUrl
$list = $web.GetList($listUrl)

function ProcessFolder {
    param($folderUrl)
    $folder = $web.GetFolder($folderUrl)
    foreach ($file in $folder.Files) {
        #Ensure destination directory
        $destinationfolder = $destination + "/" + $folder.Url 
        if (!(Test-Path -path $destinationfolder))
        {
            $dest = New-Item $destinationfolder -type directory 
        }
        #Download file
        $binary = $file.OpenBinary()
        $stream = New-Object System.IO.FileStream($destinationfolder + "/" + $file.Name), Create
        $writer = New-Object System.IO.BinaryWriter($stream)
        $writer.write($binary)
        $writer.Close()
        }
}

#Download root files
ProcessFolder($list.RootFolder.Url)
#Download files in folders
foreach ($folder in $list.Folders) {
    ProcessFolder($folder.Url)
}