# Removes CD/DVD from templates

$templates = Get-Template
 
foreach($tpl in $templates){

    $vm = Set-Template -Template (Get-Template $tpl) -ToVM
 
    Get-CDDrive -VM $vm | Set-CDDrive -NoMedia -Confirm:$false | Out-Null

    ($vm | Get-View).MarkAsTemplate() | Out-Null

}
