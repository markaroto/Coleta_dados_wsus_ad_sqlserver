$servidor_ad="ad_server"
$servidor_sql="SQLSERVER2014"
$tabela_sql="tab_ad"
$banco_sql="rel_comp"
New-PSSession -ComputerName $servidor_ad
$ad_aquivos=Invoke-Command -ComputerName $servidor_ad -ScriptBlock {Get-ADComputer -Filter {enabled -eq $true} -Properties * | select name,PasswordLastSet,OperatingSystem,IPv4Address,CanonicalName}
Remove-PSSession  -ComputerName $servidor_ad
sqlcmd  -S ${servidor_sql} -Q "delete from ${banco_sql}.dbo.${tabela_sql};";
foreach ($hostname in ($ad_aquivos | select name)){
    $ac_ad= $ad_aquivos | where {$_.name -like ($hostname | select name).name}    
    $nome= ($ac_ad | select name).name
    if(($ac_ad).PasswordLastSet){
        $LastLogonDate = ($ac_ad | select PasswordLastSet).PasswordLastSet.ToString("MM/dd/yyyy HH:mm:ss")
    }else {
        $LastLogonDate =$null
    }
    $OperatingSystem = ($ac_ad | select OperatingSystem).OperatingSystem
    $IPv4Address= ($ac_ad | select IPv4Address).IPv4Address
    $CanonicalName=($ac_ad | select CanonicalName).CanonicalName
    sqlcmd  -S ${servidor_sql} -Q "insert into ${banco_sql}.dbo.${tabela_sql} (ad_name,ad_ultimo_pwd,ad_sistema,ad_ipv4,AD_local) values('$nome','$LastLogonDate','$OperatingSystem','$IPv4Address','$CanonicalName')"; 
    
}
