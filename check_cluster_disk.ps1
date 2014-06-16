param($filter_name,$filter_exp,[Int32]$warn=85,[Int32]$crit=95)
$computer = $env:COMPUTERNAME
$filter = "$filter_name='$filter_exp'"

$ReturnCode = 3
$disk_exists = 0

Get-WmiObject -Class MSCluster_DiskPartition -Filter $filter -ComputerName $computer -Namespace ROOT\MSCluster  |
    Select-Object Path, VolumeLabel, VolumeGuid, FreeSpace,TotalSize |
    ForEach-Object { 

        $free = ($_.FreeSpace/$_.TotalSize*100)
        $free = [math]::floor($free)

        if ($free -le $crit){
		$ReturnCode=2
	        Write-Host "DISK CRITICAL - Free Space :"`"$($_.VolumeLabel)`" $_.Path $_.TotalSize  `($free%`)
	}
        elseif ($free -le $warn -and $ReturnCode -ne 2){
		$ReturnCode=1
	        Write-Host "DISK WARNING - Free Space :"`"$($_.VolumeLabel)`" $_.Path $_.TotalSize MB  `($free%`)
	}
        elseif ($free -gt $warn -and $ReturnCode -ne 2 -and $ReturnCode -ne 1){
		$ReturnCode=0
	        Write-Host "DISK OK - Free Space :"`"$($_.VolumeLabel)`" $_.Path $_.TotalSize MB  `($free%`)
	}

        Write-Host "Free Space :" `" $_.VolumeLabel `" $_.Path $_.TotalSize MB  `($free%`)  `| "$($_.VolumeGuid)=$free%;$warn;$crit"

	$disk_exists = 1
}


if ($disk_exists -eq 0)
{
	Write-Host Disk `"$filter`" does not exist
	exit 3
}


exit $ReturnCode
