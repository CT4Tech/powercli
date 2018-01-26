# Exports port groups from dvSwitch, ready to import into another dvSwitch
$switch = read-host -prompt 'Enter dvSwitch to export'

Get-VDSwitch -Name $switch | Get-VDPortgroup | Foreach {
Export-VDPortGroup -VDPortGroup $_ -Description 'Backup of $($_.Name) PG' -Destination 'C:\Users\temp\scripts\$($_.Name).Zip'
}
