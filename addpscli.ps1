#----------------------------------

#       VMware.ps1

#       Created by Ken Kellestine

#       Jan 2 2013

#----------------------------------

#       Loads the PowerCLI Module

#       And prompts to connect to

#           the vCenter server

#----------------------------------
 


 $vCenterIP = read-host -prompt 'Enter IP or DNS name of vCenter server'
 
try{

    #Import the PowerCLI module

    Add-PSSnapin VMware.VimAutomation.Core
 
    #Update the title bar

    $host.ui.rawui.WindowTitle="PowerShell [PowerCLI Module Loaded]"

 
    #Ask the user if we should connect to the vCenter server

    $ans = Read-Host "Connect to $vCenterIP [Y/N]"

    if ($ans -eq "Y" -or $ans -eq "y"){

 
        #It takes some time to connect, let the user know they should expect a delay

        "Connecting, please wait.."

 
        #Connect to the server

        Connect-VIServer $vCenterIP

    }else{

 
        #Display the connection syntax to help the user connect manually in the future

        "Use Connect-VIServer [server] to connect when ready"

    }

}

catch {
    #Something failed. Opps

    "Failed to load the PowerShell CLI"
}
