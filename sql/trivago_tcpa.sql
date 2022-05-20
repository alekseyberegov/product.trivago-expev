select c.crunch_date
	, (select top 1 roas 
		from exploratory.trivago_exrev_roas re 
		where partition_date <= '${crunch_date}' 
			and re.market = c.mrkt 
				and nvl(re.vertical,c.vert) = c.vert
		order by partition_date desc) as roas
	, c.placement_id
	, c.tracking_id
	, c.mrkt
	, c.vert
	, c.mrkt_vert
	, max_tcpa
	, rates_eur
	, campaign_id
	, publisher_id
	, cost_pm_usd_07
	, cost_pm_usd_14
	, cost_pm_usd_30
	, click_cnt_pm_07
	, click_cnt_pm_14
	, click_cnt_pm_30
	, co_cnt_pm_07
	, co_cnt_pm_14
	, co_cnt_pm_30
	, co_cnt_bt_07
	, co_cnt_bt_14
	, co_cnt_bt_30
	, co_cnt_mv_07
	, co_cnt_mv_14
	, co_cnt_mv_30
	, cost_bt_usd_07
	, cost_bt_usd_14
	, cost_bt_usd_30
	, cost_mv_usd_07
	, cost_mv_usd_14
	, cost_mv_usd_30
	, click_cnt_bt_07
	, click_cnt_bt_14
	, click_cnt_bt_30
	, click_cnt_mv_07
	, click_cnt_mv_14
	, click_cnt_mv_30
	, nvl(attr_bookings_7,  0) as attr_bookings_07
	, nvl(attr_bookings_14, 0) as attr_bookings_14
	, nvl(attr_bookings_30, 0) as attr_bookings_30
	, nvl(exrev_pm_eur_07,  0) as exrev_pm_eur_07
	, nvl(exrev_pm_eur_14,  0) as exrev_pm_eur_14
	, nvl(exrev_pm_eur_30,  0) as exrev_pm_eur_30
	, nvl(exrev_pm_usd_07,  0) as exrev_pm_usd_07
	, nvl(exrev_pm_usd_14,  0) as exrev_pm_usd_14
	, nvl(exrev_pm_usd_30,  0) as exrev_pm_usd_30
	, nvl(exrev_mv_eur_07,  0) as exrev_mv_eur_07
	, nvl(exrev_mv_eur_14,  0) as exrev_mv_eur_14
	, nvl(exrev_mv_eur_30,  0) as exrev_mv_eur_30
	, nvl(exrev_mv_usd_07,  0) as exrev_mv_usd_07
	, nvl(exrev_mv_usd_14,  0) as exrev_mv_usd_14
	, nvl(exrev_mv_usd_30,  0) as exrev_mv_usd_30
	, sum(nvl(exrev_pm_eur_07, 0)) over(partition by tracking_id) as exrev_bt_eur_07
	, sum(nvl(exrev_pm_eur_14, 0)) over(partition by tracking_id) as exrev_bt_eur_14
	, sum(nvl(exrev_pm_eur_30, 0)) over(partition by tracking_id) as exrev_bt_eur_30
	, sum(nvl(exrev_pm_usd_07, 0)) over(partition by tracking_id) as exrev_bt_usd_07
	, sum(nvl(exrev_pm_usd_14, 0)) over(partition by tracking_id) as exrev_bt_usd_14
	, sum(nvl(exrev_pm_usd_30, 0)) over(partition by tracking_id) as exrev_bt_usd_30
	, decode(co_cnt_pm_07, 0, NULL, exrev_pm_usd_07 / roas / co_cnt_pm_07) as tcpa_pm_usd_07
	, decode(co_cnt_pm_14, 0, NULL, exrev_pm_usd_14 / roas / co_cnt_pm_14) as tcpa_pm_usd_14
	, decode(co_cnt_pm_30, 0, NULL, exrev_pm_usd_30 / roas / co_cnt_pm_30) as tcpa_pm_usd_30
	, decode(co_cnt_bt_07, 0, NULL, exrev_bt_usd_07 / roas / co_cnt_bt_07) as tcpa_bt_usd_07
	, decode(co_cnt_bt_14, 0, NULL, exrev_bt_usd_14 / roas / co_cnt_bt_14) as tcpa_bt_usd_14
	, decode(co_cnt_bt_30, 0, NULL, exrev_bt_usd_30 / roas / co_cnt_bt_30) as tcpa_bt_usd_30
	, decode(co_cnt_mv_07, 0, NULL, exrev_mv_usd_07 / roas / co_cnt_mv_07) as tcpa_mv_usd_07
	, decode(co_cnt_mv_14, 0, NULL, exrev_mv_usd_14 / roas / co_cnt_mv_14) as tcpa_mv_usd_14
	, decode(co_cnt_mv_30, 0, NULL, exrev_mv_usd_30 / roas / co_cnt_mv_30) as tcpa_mv_usd_30
from (
	select crunch_date
	    , placement_id
	    , tracking_id
	    , substring(placement_id, 1, 5) as mrkt_vert
	    , upper(substring(placement_id, 1, 2)) as mrkt
	  	, upper(substring(placement_id, 4, 2)) as vert
		, campaign_id
		, publisher_id
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <=  6 then cost_usd else 0 end) as cost_pm_usd_07
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <= 13 then cost_usd else 0 end) as cost_pm_usd_14
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <= 29 then cost_usd else 0 end) as cost_pm_usd_30
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <=  6 then click_cnt else 0 end) as click_cnt_pm_07
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <= 13 then click_cnt else 0 end) as click_cnt_pm_14
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <= 29 then click_cnt else 0 end) as click_cnt_pm_30
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <=  6 then co_cnt else 0 end) as co_cnt_pm_07
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <= 13 then co_cnt else 0 end) as co_cnt_pm_14
		, sum(case when date_diff('day', utc_date::date, crunch_date::date) <= 29 then co_cnt else 0 end) as co_cnt_pm_30
		, sum(co_cnt_pm_07) over(partition by tracking_id) as co_cnt_bt_07
		, sum(co_cnt_pm_14) over(partition by tracking_id) as co_cnt_bt_14
		, sum(co_cnt_pm_30) over(partition by tracking_id) as co_cnt_bt_30
		, sum(co_cnt_pm_07) over(partition by mrkt_vert) as co_cnt_mv_07
		, sum(co_cnt_pm_14) over(partition by mrkt_vert) as co_cnt_mv_14
		, sum(co_cnt_pm_30) over(partition by mrkt_vert) as co_cnt_mv_30
		, sum(cost_pm_usd_07) over(partition by tracking_id) as cost_bt_usd_07
		, sum(cost_pm_usd_14) over(partition by tracking_id) as cost_bt_usd_14
		, sum(cost_pm_usd_30) over(partition by tracking_id) as cost_bt_usd_30
		, sum(cost_pm_usd_07) over(partition by mrkt_vert) as cost_mv_usd_07
		, sum(cost_pm_usd_14) over(partition by mrkt_vert) as cost_mv_usd_14
		, sum(cost_pm_usd_30) over(partition by mrkt_vert) as cost_mv_usd_30
		, sum(click_cnt_pm_07) over(partition by tracking_id) as click_cnt_bt_07
		, sum(click_cnt_pm_14) over(partition by tracking_id) as click_cnt_bt_14
		, sum(click_cnt_pm_30) over(partition by tracking_id) as click_cnt_bt_30
		, sum(click_cnt_pm_07) over(partition by mrkt_vert) as click_cnt_mv_07
		, sum(click_cnt_pm_14) over(partition by mrkt_vert) as click_cnt_mv_14
		, sum(click_cnt_pm_30) over(partition by mrkt_vert) as click_cnt_mv_30
	from exploratory.trivago_performance_agg
	group by 1, 2, 3, 4, 5, 6, 7, 8
) c left join (
	select crunch_date 
		, cip_tc as placement_id
		, attr_bookings_7
		, attr_bookings_14
		, attr_bookings_30
		, substring(cip_tc, 1, 5) as mrkt_vert
		, exrev_7  as exrev_pm_eur_07
		, exrev_14 as exrev_pm_eur_14
		, exrev_30 as exrev_pm_eur_30
		, rates_eur
		, exrev_7  / rates_eur as exrev_pm_usd_07
		, exrev_14 / rates_eur as exrev_pm_usd_14
		, exrev_30 / rates_eur as exrev_pm_usd_30
		, sum(exrev_7 ) over(partition by mrkt_vert) as exrev_mv_eur_07
		, sum(exrev_14) over(partition by mrkt_vert) as exrev_mv_eur_14
		, sum(exrev_30) over(partition by mrkt_vert) as exrev_mv_eur_30
		, sum(exrev_pm_usd_07) over(partition by mrkt_vert) as exrev_mv_usd_07
		, sum(exrev_pm_usd_14) over(partition by mrkt_vert) as exrev_mv_usd_14
		, sum(exrev_pm_usd_30) over(partition by mrkt_vert) as exrev_mv_usd_30
	from exploratory.trivago_exrev er 
		left join exploratory.currency_exchange_rates fx on (er.crunch_date = fx.partition_date)
	where er.partition_date >= '${crunch_date}'
) e using (crunch_date, placement_id)
left join exploratory.trivago_max_tcpa tmt on (tmt.country = c.mrkt)
where c.crunch_date =  '${crunch_date}'
