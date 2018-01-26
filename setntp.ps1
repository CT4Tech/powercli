#Configure NTP server

$cluster = Read-Host -prompt 'Enter cluster to configure'

get-cluster $cluster | get-vmhost | Add-VmHostNtpServer -NtpServer pool.ntp.org
#Allow NTP queries outbound through the firewall
get-cluster $cluster | get-vmhost | Get-VMHostFirewallException | where {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true
#Start NTP client service and set to automatic
get-cluster $cluster | get-vmhost | Get-VmHostService | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService
get-cluster $cluster | get-vmhost | Get-VmHostService | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"
