with optimize as (
	select  100 as min_spend
		, 0.001 as min_tcpa
		,  0.2  as max_up_pct
		, -0.2  as max_dn_pct
)
select c.crunch_date::date - 1 as start_date
	, c.crunch_date
	, c.tracking_id
	, c.placement_id
	, case when c.cost_pm_usd_07 >= opt.min_spend and nvl(tcpa_pm_usd_07, 0) > 0 then c.tcpa_pm_usd_07 end as tcpa_0_pm_usd_07
	, case when c.cost_pm_usd_14 >= opt.min_spend and nvl(tcpa_pm_usd_14, 0) > 0 then c.tcpa_pm_usd_14 end as tcpa_0_pm_usd_14
	, case when c.cost_pm_usd_30 >= opt.min_spend and nvl(tcpa_pm_usd_30, 0) > 0 then c.tcpa_pm_usd_30 end as tcpa_0_pm_usd_30
	, case when c.cost_bt_usd_07 >= opt.min_spend and nvl(tcpa_bt_usd_07, 0) > 0 then c.tcpa_bt_usd_07 end as tcpa_0_bt_usd_07
	, case when c.cost_bt_usd_14 >= opt.min_spend and nvl(tcpa_bt_usd_14, 0) > 0 then c.tcpa_bt_usd_14 end as tcpa_0_bt_usd_14
	, case when c.cost_bt_usd_30 >= opt.min_spend and nvl(tcpa_bt_usd_30, 0) > 0 then c.tcpa_bt_usd_30 end as tcpa_0_bt_usd_30
	, case when c.cost_mv_usd_07 >= opt.min_spend and nvl(tcpa_mv_usd_07, 0) > 0 then c.tcpa_mv_usd_07 end as tcpa_0_mv_usd_07
	, case when c.cost_mv_usd_14 >= opt.min_spend and nvl(tcpa_mv_usd_14 ,0) > 0 then c.tcpa_mv_usd_14 end as tcpa_0_mv_usd_14
	, case when c.cost_mv_usd_30 >= opt.min_spend and nvl(tcpa_mv_usd_30 ,0) > 0 then c.tcpa_mv_usd_30 end as tcpa_0_mv_usd_30
	, coalesce(
		tcpa_0_pm_usd_07, tcpa_0_pm_usd_14, tcpa_0_pm_usd_30,
		tcpa_0_bt_usd_07, tcpa_0_bt_usd_14, tcpa_0_bt_usd_30, 
		tcpa_0_mv_usd_07, tcpa_0_mv_usd_14, tcpa_0_mv_usd_30
	  ) as tcpa_0_usd
	, opt.min_tcpa
	, tmt.max_tcpa 
	, case 
		when tcpa_0_usd > tmt.max_tcpa then tmt.max_tcpa
		when tcpa_0_usd < opt.min_tcpa then opt.min_tcpa
		else tcpa_0_usd
	  end as tcpa_1_usd
	, tft.tcpa_usd as prev_tcpa_usd
	, case 
		when nvl(tft.tcpa_usd, 0) > 0 and tcpa_1_usd / tft.tcpa_usd - 1 > opt.max_up_pct then (1 + opt.max_up_pct) * tft.tcpa_usd
		when nvl(tft.tcpa_usd, 0) > 0 and tcpa_1_usd / tft.tcpa_usd - 1 < opt.max_dn_pct then (1 - opt.max_dn_pct) * tft.tcpa_usd
		else tcpa_1_usd
	 end as tcpa_usd
from exploratory.trivago_tcpa c cross join optimize opt
	left join exploratory.trivago_max_tcpa tmt on (tmt.country = c.mrkt)
	left join exploratory.trivago_fin_tcpa tft on (tft.crunch_date::date - 1 = c.crunch_date and tft.placement_id = c.placement_id)
where c.crunch_date =  '${crunch_date}'
