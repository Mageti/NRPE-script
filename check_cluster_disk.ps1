
param($filter_name,$filter_exp,[Int32]$warn=15,[Int32]$crit=5)
$computer = $env:COMPUTERNAME
$filter = "$filter_name='$filter_exp'"

$ReturnCode = 3
$disk_exists = 0

Get-WmiObject -Class MSCluster_DiskPartition -Filter $filter -ComputerName $computer -Namespace ROOT\MSCluster  |
    Select-Object Path, VolumeLabel, VolumeGuid, FreeSpace,TotalSize |
    ForEach-Object { 

        $free = ($_.FreeSpace/$_.TotalSize*100)
        $free = [math]::floor($free)

        if ($free -le $crit){$ReturnCode=2}
        elseif ($free -le $warn -and $ReturnCode -ne 2){$ReturnCode=1}
        elseif ($free -gt $warn -and $ReturnCode -ne 2 -and $ReturnCode -ne 1){$ReturnCode=0}

        Write-Host `" $_.VolumeLabel `" $_.Path "- Free Space :" $free% / $_.TotalSize MB

	$disk_exists = 1
}


if ($disk_exists -eq 0)
{
Write-Host Disk `"$filter`" does not exist
exit 3
}


exit $ReturnCode
