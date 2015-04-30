$TotalGB = @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}
 $FreeGB = @{Name="FreeSpace(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}
 $FreePerc = @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),0)}}
 
function get-mountpoints {
 $volumes = Get-WmiObject -computer $server win32_volume | Where-object {$_.DriveLetter -eq $null}
 $volumes | Select SystemName, Label, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
 }
 
$servers = (Get-Content "C:\Scripts\Array Files\mount_point_queries.txt")
 
foreach ($server in $servers){
 get-mountpoints
 }