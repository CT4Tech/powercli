# Copies standard virtual port groups from vswitch0 on one host to another
# Edit the vSwitch name in the line beginning $NewPortGroup to copy vSwitch1, vSwitch2, etc

# $VISRV = Connect-VIServer (Read-Host "Please enter the name of your VI SERVER")
$BASEHost Get-VMHost -Name (Read-Host "Please enter the name of your existing server as seen in the VI Client:")
$NEWHost = Get-VMHost -Name (Read-Host "Please enter the name of the server to configure as seen in the VI Client:")
 
# $BASEHost | Get-VirtualSwitch | Foreach {
#   If (($NEWHost | Get-VirtualSwitch -Name $_.Name -ErrorAction SilentlyContinue) -eq $null){
#       Write-Host "Creating Virtual Switch $($_.Name)"
#       $NewSwitch = $NEWHost | New-VirtualSwitch -Name $_.Name -NumPorts $_.NumPorts -Mtu $_.Mtu
#       $vSwitch = $_
#    }
$BASEHost | get-virtualswitch -name vswitch0 | Get-VirtualPortGroup | Foreach {
       If (($NEWHost | Get-VirtualPortGroup -Name $_.Name -ErrorAction SilentlyContinue) -eq $null){
           Write-Host "Creating Portgroup $($_.Name)"
           $NewPortGroup = $NEWHost | Get-VirtualSwitch -Name vSwitch0 | New-VirtualPortGroup -Name $_.Name -VLanId $_.VLanID
        }
    }
# }
