with trivago_roas as (
	select 
		 report_date 						as utc_date
		,advertiser_tracking_id 			as placement_id
		,sum(clickouts_cnt) 				as co_cnt
		,sum(advertiser_revenue_amt)		as co_rev_usd
		,sum(local_advertiser_revenue_amt)	as co_rev_eu
		,sum(bookings_cnt) 					as book_cnt
	from lake.trivago_roas 
	where report_date >= '${crunch_date}' - 32
	group by 1,2
),
ct_rev as (
	select
		  utc_date
		, advertiser_id
		, campaign_id
		, publisher_id
		, placement_id
		, sum(click_cnt) as click_cnt
		, sum(cost_usd)  as cost_usd
	from (
		select
			 trunc(convert_timezone('PST', 'UTC', date)) as utc_date
			, advertiser_id
			, campaign_id
			, publisher_id
			, replace(tracking_id, '{ctPublisherID}', publisher_id) as placement_id
			, count(1) as click_cnt
			, sum(advertiser_cpc) as cost_usd
		from v_all_clean_clicks 
		where advertiser_id = 156 and utc_date between cast('${crunch_date}' as date) - 32 and cast('${crunch_date}' as date)
		group by 1,2,3,4,5
		union all
		select
			 trunc(convert_timezone('PST', 'UTC', date)) as utc_date
			, advertiser_id
			, campaign_id
			, publisher_id
			, replace(tracking_id, '{ctPublisherID}', publisher_id) as placement_id
			, 0 as click_cnt
			, 0 as cost_usd
		from v_all_clicks 
		where advertiser_id = 156 and utc_date between cast('${crunch_date}' as date) - 32 and cast('${crunch_date}' as date)
		group by 1,2,3,4,5
	)
	group by 1,2,3,4,5
)
select
	cast('${crunch_date}' as date) as crunch_date
	, c.utc_date
	, coalesce(mc0."tag", mc1."tag", mc2."tag") as tracking_id
	, c.placement_id
	, c.advertiser_id
	, c.campaign_id
	, c.publisher_id
	, nvl(c.click_cnt, 0) as click_cnt
	, nvl(c.cost_usd,  0) as cost_usd
	, nvl(r.co_cnt,    0) as co_cnt
	, nvl(r.co_rev_usd,0) as co_rev_usd
	, nvl(r.co_rev_eu, 0) as co_rev_eu
	, nvl(r.book_cnt,  0) as book_cnt
	, ma.name as advertiser_name
	, mc.name as campaign_name
	, mp.name as publisher_name
from ct_rev c
	left join trivago_roas r using (utc_date, placement_id)
	left join metadata_advertisers ma on ma.id = c.advertiser_id
	left join metadata_publishers mp  on mp.id = c.publisher_id
	left join mart.campaigns mc on mc.id = c.campaign_id 
	left join mart.campaign_tags mc0 on mc0.campaign_id = c.campaign_id and mc0.name = c.publisher_id 
	left join mart.campaign_tags mc1 on mc1.campaign_id = c.campaign_id and mc1.name = 'Bucket_NT' and c.placement_id ilike '%_nt_p%'
	left join mart.campaign_tags mc2 on mc2.campaign_id = c.campaign_id and mc2.name = 'Bucket' 
	