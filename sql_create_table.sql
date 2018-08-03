CREATE TABLE [dbo].[tab_ad](
	[ad_name] [varchar](50) NULL,
	[ad_ultimo_pwd] [datetime] NULL,
	[ad_sistema] [varchar](150) NULL,
	[ad_ipv4] [varchar](50) NULL,
	[AD_local] [varchar](450) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tab_dns](
	[dns_name] [varchar](50) NULL,
	[dns_data_ultimo] [datetime] NULL,
	[dns_IPV4] [varchar](50) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tab_wsus](
	[wsus_name] [varchar](50) NULL,
	[wsus_ultimo_reporte] [datetime] NULL,
	[wsus_sistema] [varchar](150) NULL,
	[wsus_IPV4] [varchar](50) NULL
) ON [PRIMARY]
GO

CREATE view [dbo].[v_Ad_wsus_dns] as
select a.ad_name,a.ad_ultimo_pwd,a.ad_sistema,a.ad_ipv4,AD_local,w.wsus_name,
		w.wsus_ultimo_reporte,w.wsus_sistema,w.wsus_IPV4,d.dns_name,d.dns_data_ultimo,d.dns_IPV4	
		 from rel_comp_copasa.dbo.tab_ad a  
	full join rel_comp_copasa.dbo.tab_wsus w on upper(a.ad_name)=upper(w.wsus_name)  
full join rel_comp_copasa.dbo.tab_dns d on UPPER(a.ad_name)=upper(d.dns_name);

GO

CREATE view [dbo].[v_Ad_wsus] as
select a.ad_name,a.ad_ultimo_pwd,a.ad_sistema,a.ad_ipv4,AD_local,w.wsus_name,
		w.wsus_ultimo_reporte,w.wsus_sistema,w.wsus_IPV4	
		 from rel_comp_copasa.dbo.tab_ad a  
left join rel_comp_copasa.dbo.tab_wsus w on upper(a.ad_name)=upper(w.wsus_name);
GO
