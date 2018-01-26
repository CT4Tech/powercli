#
# Created 3/5/2010
#
#
# Purpose: Creates and email snapshot report in html format for all VMs running on VMWare vSphere
#
# Usage Notice: Use at your own risk
#
# Configuration Parameters: Update your information here.
# -------------------------------------------------------------
$server = read-host -prompt 'Enter name of vCenter server'
$user = read-host -prompt 'Enter username, domain\user'
$pass = read-host -prompt 'Enter password'

$SMTPserver = read-host -prompt 'Enter SMTP server'
$from = read-host -prompt 'Enter SMTP send from address'
$to = read-host -prompt 'Enter address to send to'

# ------------------------------------------------------------

$currentdate = (Get-Date)
$htmlreport = ""

#if ( $DefaultVIServers.Length -lt 1 )
#{
#  Connect-VIServer -Server $server -Protocol https -User $user -Password $pass -WarningAction SilentlyContinue | Out-Null
#}

# Format html report
$htmlReport = @"
<style type='text/css'>
.heading {
 	color:#3366FF;
	font-size:12.0pt;
	font-weight:700;
	font-family:Verdana, sans-serif;
	text-align:left;
	vertical-align:middle;
	height:30.0pt;
	width:416pt
}
.colnames {
 	color:white;
	font-size:8.0pt;
	font-weight:700;
	font-family:Tahoma, sans-serif;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#99CC00;
}
.text {
	color:windowtext;
	font-size:8.0pt;
	font-family:Arial;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#CCCCFF;
}
</style>
<table border=0 cellpadding=0 cellspacing=0 width=555 
 style='border-collapse:collapse;table-layout:fixed;width:600pt'>
 <tr style='height:15.0pt'>
  <th colspan=5 height=40 width=555 class="heading">
	vSphere Snapshots Report</th>
 </tr>
 <tr>
  <th class="colnames">Name</th>
  <th class="colnames">Size (MB)</th>
  <th class="colnames">VM</th>
  <th class="colnames">VM State</th>
  <th class="colnames">Date Created (US format)</th>
 </tr>
"@

# $vmlist = Get-VM -Server $server
$vmlist = Get-VM
$snapshotCount = 0

ForEach ($vm in $vmlist)
{
  # List snaphosts
  $snapshots = Get-Snapshot -VM (Get-VM -Name $vm.Name) -WarningAction SilentlyContinue
  
  if ($snapshots -ne $null)
  {
      
  	ForEach ($snapshot in $snapshots | Where {$_.Created -lt ((Get-Date).AddDays(-1))})
	{
		if( $snapshot -ne $null)
     	{
		 	$snapshotCount = $snapshotCount + 1
			$htmlReport = $htmlReport + 
			  "<tr><td class='text'>" + $snapshot.Name + "</td>" +
			  "<td class='text'>" + $snapshot.SizeMB + "</td>" +
			  "<td class='text'>"+ $vm.Name + "</td>" + 
			  "<td class='text'>" + $vm.PowerState + "</td>" +
			  "<td class='text'>" + $snapshot.Created + "</td></tr>"
   	}	
  	}
 }
}

$htmlReport = $htmlReport + "<tr><td class='colnames'>" + "</td>" +
			  "<td class='colnames'>" + "Current Date (US format):" + "</td>" +
			  "<td class='colnames'>" + "</td>" + 
			  "<td class='colnames'>" + "</td>" +
			  "<td class='colnames'>" + $currentdate + "</td></tr>""</table>"

# Disconnect-VIServer -Server $server -Force:$true -Confirm:$false

# Send email
if( $snapshotCount -gt 0 )
{
$subject = $server + " vSphere Snapshot Report - Age Warning: " + $snapshotCount + " snapshots"
$emailbody = $htmlReport
$mailer = New-Object Net.Mail.SMTPclient($SMTPserver)
$msg = New-Object Net.Mail.MailMessage($from, $to, $subject, $emailbody)
$msg.IsBodyHTML = $true
$mailer.send($msg)
}
#if( $snapshotCount -gt 0 )
#{
#send-mailmessage -To $to -From $from -subject $subject -Body $emailbody -Smtpserver $SMTPserver
#}
