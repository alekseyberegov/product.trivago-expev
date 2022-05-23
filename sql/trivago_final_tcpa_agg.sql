select crunch_date::date - 1 as start_date
	, mrkt as market
	, vert as vertical
	, coalesce(tcpa_0_mv_usd_07, tcpa_0_mv_usd_14, tcpa_0_mv_usd_30) as tcpa_usd
from (
	select crunch_date, mrkt, vert	
			, min(case when c.cost_mv_usd_07 >= opt.min_spend_amt and nvl(tcpa_mv_usd_07, 0) > 0 then c.tcpa_mv_usd_07 end) as tcpa_0_mv_usd_07
			, min(case when c.cost_mv_usd_14 >= opt.min_spend_amt and nvl(tcpa_mv_usd_14 ,0) > 0 then c.tcpa_mv_usd_14 end) as tcpa_0_mv_usd_14
			, min(case when nvl(tcpa_mv_usd_30 ,0) > 0 then c.tcpa_mv_usd_30 end) as tcpa_0_mv_usd_30
	from exploratory.trivago_tcpa c 
			cross join (
				select top 1 min_spend_amt, max_up_pct, min_dn_pct, min_tcpa
				from exploratory.trivago_tcpa_params
				where crunch_date <=  '${crunch_date}'
				order by crunch_date desc
			) opt
	where crunch_date = '${crunch_date}'
	group by 1, 2, 3
) d

