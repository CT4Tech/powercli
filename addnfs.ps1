# Mounts an NFS share on all hosts in selected cluster

$name = read-host -prompt 'Enter display name of NAS'
$ip = read-host -prompt 'Enter IP address of NAS'
$path = read-host -prompt 'Enter path of share, e.g. /volume1/Data'
$cluster = read-host -prompt 'Enter name of cluster, e.g. Production'

foreach ($esx in get-cluster -Name $cluster | get-VMhost | sort Name)
{
    $esx | New-Datastore -Nfs -Name $name -NFSHost $ip -Path $path
    echo "NFS share added to $esx"
}
