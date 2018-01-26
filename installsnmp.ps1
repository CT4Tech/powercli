####################################
# Last update: 20150310pra
# Description: Powershell script to install and configure SNMP Services on Windows 2008R2, 2012 and 2012R2 Server (SNMP Service, SNMP WMI Provider)
# start As Administrator with C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -Command "&{ \\Servername\InstallSNMP\installsnmp.ps1}"
# Script Location: \\Servername\InstallSNMP\installsnmp.ps1
####################################

#Variables :)
$PManagers = @("172.29.60.206") # ADD YOUR MANAGER(s) in format @("manager1","manager2")
$CommString = @("public") # ADD YOUR COMM STRING(s) in format @("Community1","Community2")

#Import ServerManger Module
Import-Module ServerManager

#Check if SNMP-Service is already installed
$check = Get-WindowsFeature -Name SNMP-Service

If ($check.Installed -ne "True") 
    {
    #Install/Enable SNMP-Service
    Write-Host "SNMP Service Installing..."
    # Get OS Version to use the right install command
    [int]$verMajor = [environment]::OSVersion.Version | ft -property Major -HideTableHeaders -auto | Out-String
    [int]$verMinor = [environment]::OSVersion.Version | ft -property Minor -HideTableHeaders -auto | Out-String
    if ($verMajor -eq 6)
        {
        $winVer = switch ($verMinor)
            {
            0 {"Win2008"}
            1 {"Win2008R2"}
            2 {"Win2012"}
            3 {"Win2012R2"}
            }
        }
    #Install SNMP on 2008 (R2)
    if ($winVer -eq "Win2008" -or $winVer -eq "Win2008R2")
        {
        Get-WindowsFeature -name SNMP* | Add-WindowsFeature | Out-Null
        }
    #Install SNMP on 20012 (R2)
    if ($winVer -eq "Win2012" -or $winVer -eq "Win2012R2")
        {
        Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeManagementTools | Out-Null
        }
    }

$check = Get-WindowsFeature -Name SNMP-Service

##Verify Windows Services Are Enabled
If ($check.Installed -eq "True")
    {
    Write-Host "Configuring SNMP Services..."
    #Set SNMP Permitted Manager(s) ** WARNING : This will over write current settings **
#    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d localhost /f | Out-Null

    #Set SNMP Traps and SNMP Community String(s) - *Read Only*
    Foreach ($String in $CommString)
        {
        reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /f | Out-Null
        # Set the Default value to be null
        reg delete ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /ve /f | Out-Null
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $String /t REG_DWORD /d 4 /f | Out-Null
        $i = 2
#        Foreach ($Manager in $PManagers)
#            {
#            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $i /t REG_SZ /d $manager /f | Out-Null
#            reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /v $i /t REG_SZ /d $manager /f | Out-Null
#            $i++
#            }
# Allow queries from all hosts
REG Query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers
REG Delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers /va /f
REG Query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent\sysServices
REG Delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent\sysServices /va /f
REG Query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent\sysContact
REG Delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent\sysContact /va /f
REG Query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent\sysLocation
REG Delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent\sysLocation /va /f
REG Add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent /v sysServices /t REG_DWORD /d 79 /f | Out-Null
REG Add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent /v sysLocation /d "Perth, NextDC, P1" /t REG_SZ /f | Out-Null
REG Add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent /v sysContact /d "support@ct4.com" /t REG_SZ /f | Out-Null
        }
    }
Else 
    {
    Write-Host "Error: SNMP Services Not Installed"
    }
