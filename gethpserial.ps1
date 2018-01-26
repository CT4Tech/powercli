# change the variable to whatever you name your iLO
# example: -iLO or -OA etc
$ilo="-ilo"
get-vmhost | where-object {$_.Manufacturer -eq "HP" } | sort-object -Property Name | %{
 
 # Since your ESXi box is attached to vCenter by FQDN,
 # we split the string on "." and take the first
 # element [0] which is the server's short name
 $shortname = ($_.name.split(".")[0])
 
 $xml = new-object system.xml.xmldocument
 # add together $shortname and $ilo to get "server-ilo"
 $xml.load("https://$shortname$ilo/xmldata?item=ALL")
 
 new-object psobject -property @{
   "Name" = $shortname
   # Parse the XML and only grab the server serial number
   "SN" = $xml.RIMP.HSI.SBSN
   }
}