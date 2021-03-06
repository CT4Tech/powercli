# Script finds the date a VM or list of VMs were last powered off

#param([string] $dstarget,$delay="5")

#if (!$dstarget){Write-Host -ForegroundColor Red "no datastore parameter";break}

## run first:
# Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
# Connect-VIServer

## sample to get Single VM:
#$vms = Get-VM -Name "myvmname"

## sample to get all VMs on Datastore
#$myDatastore = Get-Datastore -Name $dstarget

#$vms = Get-VM -Datastore $myDatastore | where {($_.powerstate -eq “PoweredOff” -or $_.powerstate -eq “Suspended”)}

## sample to get all VMs on Datacenter

#$myDatacenter = Get-Datacenter -Name (read-host -prompt 'Enter data centre name as shown in vSphere client')
$vms = Get-VM  | where {($_.powerstate -eq “PoweredOff” -or $_.powerstate -eq “Suspended”)}

$outputArray =@()

Foreach ($vm in $vms)

{

    # retreive file path info
    $vmView = $vm|get-view -WarningAction:SilentlyContinue -ErrorAction:SilentlyContinue
    $vmLogDs = ($vmView.LayoutEx.file|?{$_.name -match "vmware.log"}).name.split("[]")[1]

    # read path to vmware.log and remove [volume name]
    $vmLogPath = (($vmView.LayoutEx.file|?{$_.name -match "vmware.log"}).name -replace "^\[.*?\] ", "").replace("/","\")

    # renew PS Drive
    $rpsd = Remove-PSDrive vids -WarningAction:SilentlyContinue -ErrorAction:SilentlyContinue
    sleep -s 1

    $npsd = New-PSDrive -Location (get-datastore $vmLogDs) -Name vids -PSProvider VimDatastore -Root '\' -Confirm:$false
    sleep -s 1

    if ((Get-Item "vids:\$vmLogPath").length -gt 100MB)
    {
        $DateInLastLine = "log too large"
    } else {
        Copy-DatastoreItem "vids:\$vmLogPath" "$env:temp\$vm.log" -force -WarningAction:SilentlyContinue -ErrorAction:SilentlyContinue

        $DateInLastLine = (Get-Content "$env:temp\$vm.log" | select -Last 1).split("|")[0].split("T")[0]        

    }

    

    # create output

    $vmOutputObject = new-object PSObject

    $vmOutputObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $vm.Name

    $vmOutputObject | Add-Member -MemberType NoteProperty -Name "Datastore" -Value $vmLogDs

    $vmOutputObject | Add-Member -MemberType NoteProperty -Name "Powerstate" -Value $vm.PowerState

    $vmOutputObject | Add-Member -MemberType NoteProperty -Name "Powered Off Date" -Value $DateInLastLine

    Write-Host ($vmOutputObject | Format-Table | Out-String)

    $outputArray += $vmOutputObject

    

    #clean up

    Remove-Item -Path "$env:temp\$vm.log" -force -WarningAction:SilentlyContinue -ErrorAction:SilentlyContinue

    $DateInLastLine = ""

    sleep -s 1

}



#csv export

$outputArray | Export-csv PoweredOffDates.csv -notypeinformation 
