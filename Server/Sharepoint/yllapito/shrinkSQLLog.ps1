<#
Currently works only in SQL server 2012

Specify instance if needed
change port if needed


#>
$instance = $env:COMPUTERNAME
$port = "1433"

Function Invoke-SQLQuery {   
    
    [CmdletBinding(DefaultParameterSetName="query")]
    Param (
        [string[]]$Instance = $env:COMPUTERNAME,
        
        [string]$Database,
        
        [Management.Automation.PSCredential]$Credential,
        [switch]$MultiSubnetFailover,
        
        [string]$Query,
        
        [Parameter(ParameterSetName="list")]
        [switch]$ListDatabases
    )

        If ($Input)
        {   $Query = $Input -join "`n"
        }

        If ($Credential)
        {   $Security = "uid=$($Credential.UserName);pwd=$($Credential.GetNetworkCredential().Password)"
        }
        Else
        {   $Security = "Integrated Security=True;"
        }
        
        If ($MultiSubnetFailover)
        {   #$MSF = "MultiSubnetFailover=yes;"
        }
        
        ForEach ($SQLServer in $Instance)
        {   $ConnectionString = "data source=$SQLServer,$port;Initial catalog=$Database;$Security;$MSF"
        
            $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
            $SqlConnection.ConnectionString = $ConnectionString
            $SqlCommand = $SqlConnection.CreateCommand()
            $SqlCommand.CommandText = $Query
            $DataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter $SqlCommand
            $DataSet = New-Object System.Data.Dataset
            Try {
                $Records = $DataAdapter.Fill($DataSet)
                If ($DataSet.Tables[0])
                {   $DataSet.Tables[0] | Add-Member -MemberType NoteProperty -Name Instance -Value $SQLServer
                    Write-Output $DataSet.Tables[0]
                }
                Else
                {   Write-host "Query did not return any records"
                }
            }
            Catch {
                Write-host "$($_.Exception.Message)"
            }
            $SqlConnection.Close()
        }
    
}
#endregion


Write-host "$(Get-Date): ShrinkSQLLog begins"
$DBsQuery = @"
WITH fs
AS
(
    SELECT database_id, name, type, size * 8.0 / 1024 AS size
    FROM sys.master_files
)
SELECT 
    db.name AS Name,
    db.database_id AS ID,
    CAST(ROUND((SELECT SUM(size) FROM fs WHERE type = 1 AND fs.database_id = db.database_id),2) AS DECIMAL(12,2)) AS LogSizeMB,
    (SELECT MAX(bus.backup_finish_date) FROM msdb.dbo.backupset AS bus JOIN fs ON bus.database_name = fs.name) AS LastBackup
FROM sys.databases AS db
WHERE db.name NOT IN ( 'master', 'model', 'msdb', 'tempdb' )
"@

Write-host "$(Get-Date): Gathering database size and backup information"
#write-host $DBsQuery
$DBs = Invoke-SQLQuery -Instance $Instance -Database Master -MultiSubnetFailover -Query $DBsQuery | Select ID,Name,FileSizeMB,LogSizeMB,LastBackup

$DBs |Format-Table name, logsizemb
read-host "Press Enter to continue. Or press ctrl+c to abort" 

$Selected = @($DBs) 
    
Write-host "$(Get-Date): $($Selected.Count) logs have been selected to be shrunk"
ForEach ($Select in $Selected)
{
    $Type = [int](-not $Database)
    $Name = (Invoke-SQLQuery -Instance $Instance -Database Master -MultiSubnetFailover -Query "Select name From sys.master_files Where database_id = '$($Select.ID)' And type = 1").Name 
    If ($Name)
    {
        Write-host "$(Get-Date): Shrinking $($Select.Name) log file: $Name"
        $Result = Invoke-SQLQuery -Instance $Instance -Database $Select.Name -MultiSubnetFailover -Query "DBCC SHRINKFILE($Name,1)"
        If ($Result)
        {
            $BackupByDBQuery = @"
WITH fs
AS
(
    SELECT database_id, type, size * 8.0 / 1024 AS size
    FROM sys.master_files
)
SELECT 
    db.name,
    db.database_id,
    CAST(ROUND((SELECT SUM(size) FROM fs WHERE type = 1 AND fs.database_id = db.database_id),2) AS DECIMAL(12,2)) AS LogSizeMB
FROM sys.databases as db
WHERE name = '$($Select.Name)'
"@

            $NewSizes = Invoke-SQLQuery -Instance $Instance -Database Master -MultiSubnetFailover -Query $BackupByDBQuery
            $Select | Add-Member -MemberType NoteProperty -Name NewLogSizeMB -Value ($NewSizes.LogSizeMB)
            Write-Output $Select
        }   
    }
    Else
    {
        Throw "Something went wrong getting logical name for $($Select.Database), aborting script"
    }
}
Write-host "$(Get-Date): ShrinkSQLLog completed"