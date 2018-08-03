$servidor_wsus="wsus"
$servidor_sql="SQLSERVER2014"
$tabela_sql="tab_wsus"
$banco_sql="rel_comp"
New-PSSession -ComputerName ${servidor_wsus}
$wsus_arquivos= Invoke-Command -ComputerName ${servidor_wsus} -ScriptBlock {get-wsuscomputer | select -property @{name="computername";e={$_.FullDomainName.split(".")[0]}},IPAddress,OSDescription,LastReportedStatusTime}
Remove-PSSession -computername ${servidor_wsus}
sqlcmd  -S ${servidor_sql} -Q "delete from ${banco_sql}.dbo.${tabela_sql};";
foreach ($hostname in ($wsus_arquivos | select computername)){
    $c_wsus= $wsus_arquivos | where {$_.computername -like ($hostname).computername}
    $name=($c_wsus | select computername).computername 
    if(($c_wsus).LastReportedStatusTime){
        if($c_wsus | where {$_.LastReportedStatusTime -notmatch "01/01/0001 00:00:00"} ){
            $LastReportedStatusTime=($c_wsus | select LastReportedStatusTime).LastReportedStatusTime.ToString("MM/dd/yyyy HH:mm:ss")
        }else{
            $LastReportedStatusTime=$null
        }

    }else{
        $LastReportedStatusTime=$null
    }
    $OSDescription=($c_wsus |select OSDescription).OSDescription
    $IPAddress=($c_wsus | select IPAddress).IPAddress    
    sqlcmd  -S ${servidor_sql} -Q "insert into ${banco_sql}.dbo.${tabela_sql} (wsus_name,wsus_ultimo_reporte,wsus_sistema,wsus_IPV4) values('$name','$LastReportedStatusTime','$OSDescription','$IPAddress')";     
}