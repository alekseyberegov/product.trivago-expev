# Expected Revenue Analytics

## Data Source

* Clickouts and Clickout Revenue - `lake.trivago_roas`
```
Column                      |Value                                               |
----------------------------+----------------------------------------------------+
report_date                 |2022-05-08                                          |
upsolver_schema_version     |1                                                   |
search_key                  |24eeb46d99bd31a25bd66dec5a6e8995                    |
advertiser_tracking_id      |us_hp_p3_2501_17357                                 |
publisher_id                |2501                                                |
campaign_id                 |17357                                               |
country_code                |us                                                  |
vertical                    |Hotel                                               |
is_preload                  |false                                               |
campaign_targeting_type_id  |2                                                   |
campaign_name               |Trivago Hotel Specific US [DOM] [Mobile] [Unchecked]|
advertiser_id               |156                                                 |
advertiser_name             |Trivago Global                                      |
bookings_cnt                |0                                                   |
clickouts_cnt               |1                                                   |
advertiser_revenue_amt      |3.3808940516276214                                  |
local_advertiser_revenue_amt|3.21                                                |
```

For every `partition_date` there are `ymd` between `parition_date - 30` and `partition_date - 1`

* Expected Revenue - `exploratory.trivago_exrev`

```
Column                |Value              |
----------------------+-------------------+
locale                |ZA                 |
cip_tc                |za_nt_p1_2709_17563|
attr_bookings_7       |0                  |
attr_cos_threshold_7d |0                  |
exrev_7               |0.0                |
attr_bookings_14      |0                  |
attr_cos_threshold_14d|0                  |
exrev_14              |0.0                |
attr_bookings_30      |                   |
attr_cos_threshold_30d|0                  |
exrev_30              |                   |
crunch_date           |2022-05-15         |
partition_date        |2022-05-16         |
```

### Lookup tables
* `exploratory.currency_exchange_rates`
* `exploratory.trivago_max_tcpa`

## DOMO Cards
* https://clicktripz.domo.com/page/534626075/kpis/details/742597243

## Utilities
### Create Athena table from JSON data
* json
```
$ ./cli.sh glue --table test_table_1 --partition date ./data/json/sample_data.json
``` 
* csv
```
$ ./cli.sh glue --table trivago_max_tcpa --format csv ./data/csv/max_tcpa.csv
```
### Create Athena table from Redshift query
```
$ ./cli.sh glue --table trivago_performance_agg --partition crunch_date  ./sql/trivago_performance.sql --param crunch_date "2022-05-16" --format sql
```

```
$ ./cli.sh glue --table trivago_tcpa --partition crunch_date  ./sql/trivago_tcpa.sql --param crunch_date "2022-05-16" --format sql
```

```
$ ./cli.sh glue --table trivago_final_tcpa --partition start_date --param crunch_date "2022-05-16" --format sql ./sql/trivago_final_tcpa_init.sql
```


