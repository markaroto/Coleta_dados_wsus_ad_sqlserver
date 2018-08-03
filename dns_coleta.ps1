$servidor_sql="SQLSERVER2014"
$tabela_sql="tab_dns"
$banco_sql="rel_comp"
$servidor_dns="dns_server"
New-PSSession -ComputerName $servidor_dns
Invoke-Command -ComputerName $servidor_dns -ScriptBlock {}
$zonas=Invoke-Command -ComputerName $servidor_dns -ScriptBlock { Get-DnsServerZone }
sqlcmd  -S $servidor_sql -Q "delete from ${banco_sql}.dbo.${tabela_sql};";
$dns=$null
foreach($zona in $zonas){	
    $dns+=Invoke-Command -ComputerName $servidor_dns -ScriptBlock {Get-DnsServerResourceRecord  -ZoneName $args[0] -RRType A 	| select hostname,@{name="ip";expression={$_.RecordData.IPv4Address.IPAddressToString}},TimeToLive,Timestamp} -ArgumentList $zona.ZoneName
}
Remove-PSSession -computername $servidor_dns
$dnss=$dns | Group-Object hostname,ip |  where {$_.count -ne 1} | select @{name="hostname";expression={$_.group.hostname[0]}},@{name="ip";expression={$_.group.ip[0]}},@{name="periodo";expression={$_.Group.Timestamp[0]}} 
$dnss+=$dns | Group-Object hostname,ip |  where {$_.count -eq 1} | select @{name="hostname";expression={$_.group.hostname}},@{name="ip";expression={$_.group.ip}},@{name="periodo";expression={$_.Group.Timestamp}} 
foreach($dns_temp in $dnss){
    $hostname=$dns_temp.hostname
    $ip=$dns_temp.ip
    if(!($dns_temp | where {$_.periodo -eq $null}) ){
        $periodo=($dns_temp | select periodo).periodo.ToString("MM/dd/yyyy HH:mm:ss")
    }else{
        $periodo=$null
    }
    sqlcmd  -S $servidor_sql -Q "insert into ${banco_sql}.dbo.${tabela_sql} (dns_name,dns_data_ultimo,dns_IPV4) values('$hostname','$periodo','$ip')";
}