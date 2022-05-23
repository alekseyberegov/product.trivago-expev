select crunch_date::date - 1 as start_date
	, placement_id
	, tracking_id
	, mrkt as market
	, vert as vertical
	, tcpa_usd
from (
	select c.crunch_date
		, c.tracking_id
		, c.placement_id
		, c.mrkt
		, c.vert
		, case when c.cost_pm_usd_07 >= opt.min_spend_amt and nvl(tcpa_pm_usd_07, 0) > 0 then c.tcpa_pm_usd_07 end as tcpa_0_pm_usd_07
		, case when c.cost_pm_usd_14 >= opt.min_spend_amt and nvl(tcpa_pm_usd_14, 0) > 0 then c.tcpa_pm_usd_14 end as tcpa_0_pm_usd_14
		, case when c.cost_pm_usd_30 >= opt.min_spend_amt and nvl(tcpa_pm_usd_30, 0) > 0 then c.tcpa_pm_usd_30 end as tcpa_0_pm_usd_30
		, case when c.cost_bt_usd_07 >= opt.min_spend_amt and nvl(tcpa_bt_usd_07, 0) > 0 then c.tcpa_bt_usd_07 end as tcpa_0_bt_usd_07
		, case when c.cost_bt_usd_14 >= opt.min_spend_amt and nvl(tcpa_bt_usd_14, 0) > 0 then c.tcpa_bt_usd_14 end as tcpa_0_bt_usd_14
		, case when c.cost_bt_usd_30 >= opt.min_spend_amt and nvl(tcpa_bt_usd_30, 0) > 0 then c.tcpa_bt_usd_30 end as tcpa_0_bt_usd_30
		, case when c.cost_mv_usd_07 >= opt.min_spend_amt and nvl(tcpa_mv_usd_07, 0) > 0 then c.tcpa_mv_usd_07 end as tcpa_0_mv_usd_07
		, case when c.cost_mv_usd_14 >= opt.min_spend_amt and nvl(tcpa_mv_usd_14 ,0) > 0 then c.tcpa_mv_usd_14 end as tcpa_0_mv_usd_14
		, case when nvl(tcpa_mv_usd_30 ,0) > 0 then c.tcpa_mv_usd_30 end as tcpa_0_mv_usd_30
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
		, tcpa_1_usd as prev_tcpa_usd
		, case 
			when nvl(prev_tcpa_usd, 0) > 0 and tcpa_1_usd / prev_tcpa_usd - 1 > opt.max_up_pct then (1 + opt.max_up_pct) * prev_tcpa_usd
			when nvl(prev_tcpa_usd, 0) > 0 and tcpa_1_usd / prev_tcpa_usd - 1 < opt.min_dn_pct then (1 + opt.min_dn_pct) * prev_tcpa_usd
			else tcpa_1_usd
		 end as tcpa_usd
	from exploratory.trivago_tcpa c 
		cross join (
			select top 1 min_spend_amt, max_up_pct, min_dn_pct, min_tcpa
			from exploratory.trivago_tcpa_params
			where crunch_date <=  '${crunch_date}'
			order by crunch_date desc
		) opt
		left join exploratory.trivago_max_tcpa tmt on (tmt.country = c.mrkt)
	where c.crunch_date =  '${crunch_date}'
) d
