with optimize as (
	select  100 as min_spend
		, 0.001 as min_tcpa
		,  0.2  as max_up_pct
		, -0.2  as max_down_pct
)
select c.crunch_date
	, c.tracking_id
	, c.placement_id
	, decode(c.cost_usd_7     >= opt.min_spend and nvl(tcpa_usd_7,     0) > 0, true, c.tcpa_usd_7,     NULL) as tcpa_0_usd_7
	, decode(c.cost_usd_14    >= opt.min_spend and nvl(tcpa_usd_14,    0) > 0, true, c.tcpa_usd_14,    NULL) as tcpa_0_usd_14
	, decode(c.cost_usd_30    >= opt.min_spend and nvl(tcpa_usd_30,    0) > 0, true, c.tcpa_usd_30,    NULL) as tcpa_0_usd_30
	, decode(c.cost_usd_bt_7  >= opt.min_spend and nvl(tcpa_bt_usd_7 , 0) > 0, true, c.tcpa_bt_usd_7,  NULL) as tcpa_0_bt_usd_7
	, decode(c.cost_usd_bt_14 >= opt.min_spend and nvl(tcpa_bt_usd_14, 0) > 0, true, c.tcpa_bt_usd_14, NULL) as tcpa_0_bt_usd_14
	, decode(c.cost_usd_bt_30 >= opt.min_spend and nvl(tcpa_bt_usd_30, 0) > 0, true, c.tcpa_bt_usd_30, NULL) as tcpa_0_bt_usd_30
	, decode(c.cost_usd_mv_7  >= opt.min_spend and nvl(tcpa_mv_usd_7 , 0) > 0, true, c.tcpa_mv_usd_7,  NULL) as tcpa_0_mv_usd_7
	, decode(c.cost_usd_mv_14 >= opt.min_spend and nvl(tcpa_mv_usd_14 ,0) > 0, true, c.tcpa_mv_usd_14, NULL) as tcpa_0_mv_usd_14
	, decode(c.cost_usd_mv_30 >= opt.min_spend and nvl(tcpa_mv_usd_30 ,0) > 0, true, c.tcpa_mv_usd_30, NULL) as tcpa_0_mv_usd_30
	, coalesce(
		tcpa_0_usd_7, 	 tcpa_0_usd_14,    tcpa_0_usd_30,
		tcpa_0_bt_usd_7, tcpa_0_bt_usd_14, tcpa_0_bt_usd_30, 
		tcpa_0_mv_usd_7, tcpa_0_mv_usd_14, tcpa_0_mv_usd_30
	  ) as cpa_0_usd
	, tmt.max_tcpa 
	, decode(cpa_0_usd > tmt.max_tcpa, true, tmt.max_tcpa, cpa_0_usd) as cpa_1_usd
	, decode(cpa_0_usd < opt.min_tcpa, true, opt.min_tcpa, cpa_1_usd) as cpa_2_usd
	, tft.tcpa_usd as prev_tcpa_usd
	, case 
		when nvl(tft.tcpa_usd, 0) > 0 and cpa_2_usd / tft.tcpa_usd - 1 > opt.max_up_pct 
			then (1 + opt.max_up_pct) * tft.tcpa_usd
		when nvl(tft.tcpa_usd, 0) > 0 and cpa_2_usd / tft.tcpa_usd - 1 < opt.max_down_pct 
			then (1 - opt.max_down_pct) * tft.tcpa_usd
		else cpa_2_usd
	 end as tcpa_usd
from exploratory.trivago_tcpa c 
	cross join optimize opt
	left join exploratory.trivago_max_tcpa tmt on (tmt.country = c.mrkt)
	left join exploratory.trivago_final_tcpa tft 
		on (tft.crunch_date::date - 1 = c.crunch_date and tft.placement_id = c.placement_id)
where c.crunch_date =  '${crunch_date}'