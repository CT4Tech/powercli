# Script will look in vCenter for VMs that are powered on, don't have "replica" or "DR" after the name
# and are currently powered on. This should mean that it ignores Veeam replicas
# It will output the result into a text file called snapps.txt in the current folder
# Written by Wayne Moore 21/07/2015

$vmlist = get-vm | where {$_.name -ne "*replica" -and $_.name -ne "*DR" -and $_.powerstate -eq "poweredon"}
$vmlist | get-snapshot | format-list vm,description,created,sizemb,iscurrent | out-file snaps.txt