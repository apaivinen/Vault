$computer = $env:COMPUTERNAME

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
					#Begin iterating through Updates available for installation 
                    Write-host "Iterating through list of updates" 
                    For ($i=0; $i -lt $Count; $i++) { 
                        #Create object holding update 
                        $Update = $searchresult.Updates.Item($i)
						
						if($Update.MsrcSeverity -eq 'Critical')
						{ 
						#	write-host $Update.MsrcSeverity -foregroundcolor "cyan";		
							$CriticalUpdates++;
						}
						if($Update.MsrcSeverity -eq 'Important')
						{ 
						#	write-host $Update.MsrcSeverity -foregroundcolor "green";
							$ImportantUpdates++ ;
						}if($Update.MsrcSeverity -le '')
						{
						#	write-host "Optional" -foregroundcolor "red";
							$OptionalUpdates++;
						}else{}
						
#						[pscustomobject]@{
#							Computername = $Computer
#							Title = $Update.Title
#							KB = $($Update.KBArticleIDs)
#							SecurityBulletin = $($Update.SecurityBulletinIDs)
#							MsrcSeverity = $Update.MsrcSeverity
#							IsDownloaded = $Update.IsDownloaded
#							Url = $($Update.MoreInfoUrls)
#							Categories = ($Update.Categories | Select-Object -ExpandProperty Name)
#							BundledUpdates = @($Update.BundledUpdates)|ForEach{
#								[pscustomobject]@{
#								Title = $_.Title
#								DownloadUrl = @($_.DownloadContents).DownloadUrl
#								}
#							}
#						} 
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