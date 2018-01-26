# Script outputs all VM IP addresses

Write-Host "Device" "`t" "Speed" "`t`t" "Configured" "`t" "vSwitch" "`t" "Observed IP ranges" "`t`t" "WOL"

Get-VMHost | Sort-Object -property Name | Get-View | % {
     Write-Host "ESX : " $_.Name

     foreach($pnic in $_.Config.Network.Pnic){
          $device = $pnic.Device
          $speed = [string]($pnic.LinkSpeed.SpeedMb)
          if($pnic.LinkSpeed.Duplex){$speed += " Full"}
          foreach($vs in $_.Config.Network.Vswitch){
               foreach($pn in $vs.Pnic){
                    if($pn -eq $pnic.Key){$vswitch = $vs.Name}
               }
          }
        $configured = ""
          if($pnic.Spec.LinkSpeed -eq $null){
            $configured = "Negotiate"
          } 
          $netSys = Get-View $_.ConfigManager.NetworkSystem
          $IPrange = ""
          $hintinfo = $netSys.QueryNetworkHint($pnic.Device)
          foreach($pnicHintInfo in $hintinfo){
               foreach($pnicIPHint in $pnicHintInfo.subnet){
                    $IPrange += $pnicIPHint.IpSubnet
                    if($pnicIPHint.VlanId -ne 0){
                      $IPrange += (" (VLAN " + $pnicIPHint.VlanId + ")")
                    }
                    if($pnicHintInfo.Subnet.Count -gt 1){
                      $IPrange += ","
                    }
               }
          }
          if($pnic.WakeOnLanSupported) {$WOL = "Yes"} else {$WOL = "No"}

          Write-Host $device "`t" $speed "`t" $configured "`t" $vswitch "`t" $IPrange "`t" $WOL
     }
}
