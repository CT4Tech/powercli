# Get serial number of ESXi hosts

Get-VMHost |Sort Name |Get-View |
Select Name,
@{N='Type';E={$_.Hardware.SystemInfo.Vendor+ ' ' + $_.Hardware.SystemInfo.Model}},
@{N='Serial Number';E={$_.Hardware.SystemInfo.OtherIdentifyingInfo[0].IdentifierValue+ ' ' }},
@{N='CPU';E={'PROC:' + $_.Hardware.CpuInfo.NumCpuPackages + ' CORES:' + $_.Hardware.CpuInfo.NumCpuCores + ' MHZ: ' + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},
@{N='MEM';E={'' + [math]::round($_.Hardware.MemorySize / 1GB, 0) + ' GB'}}
