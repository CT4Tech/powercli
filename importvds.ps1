# Script imports previously exported dvPortGroups into dvSwitch

$folder = read-host -prompt 'Enter path to folder containing port group backups to import, e.g. C:\Temp\Portgroups'
$switch = read-host -prompt 'Enter name of dvSwitch to import into'

Get-ChildItem $folder | Foreach {
New-VDPortgroup -VDSwitch $switch -Name '($_.BaseName)' -BackupPath $_.FullName
}
