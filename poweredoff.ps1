 Script to extract the last boot time of vms
 
# russ 11/08/2015
# Credits http://vmware-scripts.blogspot.com.es/2012/08/script-to-get-uptime-of-each-vm-in.html
 
# Create array to select the cluster
Clear      
    # Getting Cluster info  
    $Cluster = Get-Cluster
    $countCL = 0 
    Clear  
    Write-Output " "
    Write-Output "Clusters: "
    Write-Output " "
    foreach($oC in $Cluster){ 
      
        Write-Output "[$countCL] $oc"
        $countCL = $countCL+1 
        } 
    $choice = Read-Host "On which cluster do you want to check the vm uptimes ?"
    $cluster = get-cluster $cluster[$choice]
   
    Write-Output "$cluster `n............................................................"
   
   
# variable to associate date with boot time
$LastBootProp = @{
  Name = 'LastBootTime'
    Expression = {
     ( Get-Date )  - ( New-TimeSpan -Seconds $_.Summary.QuickStats.UptimeSeconds )
}
}
 
# code; limits search for vms within cluster,
# filters for powered on vms,  and sorts boot time in descending order
Get-View -ViewType VirtualMachine -SearchRoot (get-cluster -name "$cluster").id -Filter @{"runtime.PowerState"="poweredOff"} -Property Name, Summary.QuickStats.UptimeSeconds | Select Name, $LastBootProp | sort-object -Descending -Property *
