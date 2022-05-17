# Expected Revenue Analytics

## Data Source

* Clickouts and Clickout Revenue - `exploratory.trivago_roas`
```
ymd     |click_id                        |cip_tc             |clickouts|clickout_revenue  |bookings|partition_date|
--------+--------------------------------+-------------------+---------+------------------+--------+--------------+
20220401|0facabceeae6755e7164c570719641f5|us_hc_p3_3322_17355|        1|              1.33|       0|2022-05-01    |
20220401|250697bd9f6519da65de5371151bc928|us_hc_p3_3262_17355|        1|              0.43|       0|2022-05-01    |
20220401|4461dcd5ff5a997ffd47823341ca3903|za_hc_p3_2501_17564|        1|              0.11|       0|2022-05-01    |
20220401|52bda3f1e8b1060571f2f9085977047d|uk_hp_p3_2610_17356|        1|              0.16|       0|2022-05-01    |
20220401|5df878e26324e4a1f3a4635918010016|ca_hp_p3_2501_25197|        1|              0.95|       0|2022-05-01    |
20220401|625cb6b34dfd13c8a8b64f2a472e43d0|us_hc_p3_3262_17355|        1|              1.81|       0|2022-05-01    |
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

## DOMO Cards
* https://clicktripz.domo.com/page/534626075/kpis/details/742597243
* 

