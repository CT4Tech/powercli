# Look for thick-provisioned disks

get-vm | get-view | %{

 $name = $_.name

 $_.Config.Hardware.Device | where {$_.GetType().Name -eq "VirtualDisk"} | %{

  if(!$_.Backing.ThinProvisioned){
 
   "$name has a thick provisioned disk"
 
  }

 }

}
