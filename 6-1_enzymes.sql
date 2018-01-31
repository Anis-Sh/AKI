set search_path to mimiciii;
drop table if exists  public.kentran_6_1_table_asat ;
drop table if exists  public.kentran_6_1_table_alat ;
drop table if exists  public.kentran_6_1_table_alp ;
drop table if exists  public.kentran_6_1_table_bili ;

------------------------ASAT-------------------------------------

with tab as 
(
select ce.icustay_id,min(ce.charttime)
from chartevents ce
where ce.itemid=769 --   asat
group by  ce.icustay_id
)
--select * from tab

,tab1 as
(
select ce.icustay_id, ce.itemid, ce.charttime, ce.valuenum, ce.valueuom, demo.admittime,
	--lead(charttime) OVER(ORDER BY charttime DESC) as prev_date,
	case 
	when (ce.charttime-demo.admittime) <= '24:00:00' then 1
	when (ce.charttime-demo.admittime) > '24:00:01' and (ce.charttime-demo.admittime) <= '48:00:00' then 2
	when (ce.charttime-demo.admittime) > '48:00:01' and (ce.charttime-demo.admittime) <= '72:00:00' then 3
	when (ce.charttime-demo.admittime) > '72:00:01' and (ce.charttime-demo.admittime) <= '96:00:00' then 4
	when (ce.charttime-demo.admittime) > '96:00:01' and (ce.charttime-demo.admittime) <= '120:00:00' then 5
	when (ce.charttime-demo.admittime) > '120:00:01' and (ce.charttime-demo.admittime) <= '144:00:00' then 6
	when (ce.charttime-demo.admittime) > '144:00:01' and (ce.charttime-demo.admittime) <= '168:00:00' then 7
	else NULL
	end as day
from chartevents ce
, public.kentran_2_2_database_ventiles demo
where demo.icustay_id=ce.icustay_id 
AND	ce.itemid=769 --  asat
order by ce.icustay_id, ce.charttime
)
--select * from tab1 
,tab2 as
(
select tab1.icustay_id, tab1.day, max(tab1.valuenum) as max_asat
from tab1
group by tab1.icustay_id, tab1.day, tab1.itemid
)
select * into public.kentran_6_1_table_asat from tab2 where day IS NOT NULL order by tab2.icustay_id, tab2.day;

------------------------ALAT-------------------------------------

with tab as 
(
select ce.icustay_id,min(ce.charttime)
from chartevents ce
where ce.itemid=770 --   alat
group by  ce.icustay_id
)
--select * from tab

,tab1 as
(
select ce.icustay_id, ce.itemid, ce.charttime, ce.valuenum, ce.valueuom, demo.admittime,
	--lead(charttime) OVER(ORDER BY charttime DESC) as prev_date,
	case 
	when (ce.charttime-demo.admittime) <= '24:00:00' then 1
	when (ce.charttime-demo.admittime) > '24:00:01' and (ce.charttime-demo.admittime) <= '48:00:00' then 2
	when (ce.charttime-demo.admittime) > '48:00:01' and (ce.charttime-demo.admittime) <= '72:00:00' then 3
	when (ce.charttime-demo.admittime) > '72:00:01' and (ce.charttime-demo.admittime) <= '96:00:00' then 4
	when (ce.charttime-demo.admittime) > '96:00:01' and (ce.charttime-demo.admittime) <= '120:00:00' then 5
	when (ce.charttime-demo.admittime) > '120:00:01' and (ce.charttime-demo.admittime) <= '144:00:00' then 6
	when (ce.charttime-demo.admittime) > '144:00:01' and (ce.charttime-demo.admittime) <= '168:00:00' then 7
	else NULL
	end as day
from chartevents ce, public.kentran_2_2_database_ventiles demo
where	demo.icustay_id=ce.icustay_id AND
	ce.itemid=770 --  alat
order by ce.icustay_id, ce.charttime
)
--select * from tab1 
,tab2 as
(
select tab1.icustay_id, tab1.day, max(tab1.valuenum) as max_alat
from tab1
group by tab1.icustay_id, tab1.day, tab1.itemid
)
select * into public.kentran_6_1_table_alat from tab2 where day IS NOT NULL order by tab2.icustay_id, tab2.day;

-- select * from public.kentran_6_1_table_alat
------------------------ALP-------------------------------------

with tab as 
(
select ce.icustay_id,min(ce.charttime)
from chartevents ce
where ce.itemid=773 --   alp
group by  ce.icustay_id
)
--select * from tab

,tab1 as
(
select ce.icustay_id, ce.itemid, ce.charttime, ce.valuenum, ce.valueuom, demo.admittime,
	--lead(charttime) OVER(ORDER BY charttime DESC) as prev_date,
	case 
	when (ce.charttime-demo.admittime) <= '24:00:00' then 1
	when (ce.charttime-demo.admittime) > '24:00:01' and (ce.charttime-demo.admittime) <= '48:00:00' then 2
	when (ce.charttime-demo.admittime) > '48:00:01' and (ce.charttime-demo.admittime) <= '72:00:00' then 3
	when (ce.charttime-demo.admittime) > '72:00:01' and (ce.charttime-demo.admittime) <= '96:00:00' then 4
	when (ce.charttime-demo.admittime) > '96:00:01' and (ce.charttime-demo.admittime) <= '120:00:00' then 5
	when (ce.charttime-demo.admittime) > '120:00:01' and (ce.charttime-demo.admittime) <= '144:00:00' then 6
	when (ce.charttime-demo.admittime) > '144:00:01' and (ce.charttime-demo.admittime) <= '168:00:00' then 7
	else NULL
	end as day
from chartevents ce, public.kentran_2_2_database_ventiles demo
where	demo.icustay_id=ce.icustay_id AND
	ce.itemid=773 --  asat
order by ce.icustay_id, ce.charttime
)
--select * from tab1 
,tab2 as
(
select tab1.icustay_id, tab1.day, max(tab1.valuenum) as max_alp
from tab1
group by tab1.icustay_id, tab1.day, tab1.itemid
)
select * into public.kentran_6_1_table_alp from tab2 where day IS NOT NULL order by tab2.icustay_id, tab2.day;

------------------------BiLI-------------------------------------

with tab as 
(
select ce.icustay_id,min(ce.charttime)
from chartevents ce
where ce.itemid in(1538,225690) --   total bili, total bilirubin
group by  ce.icustay_id
)
--select * from tab

,tab1 as
(
select ce.icustay_id, ce.itemid, ce.charttime, ce.valuenum, ce.valueuom, demo.admittime,
	--lead(charttime) OVER(ORDER BY charttime DESC) as prev_date,
	case 
	when (ce.charttime-demo.admittime) <= '24:00:00' then 1
	when (ce.charttime-demo.admittime) > '24:00:00' and (ce.charttime-demo.admittime) <= '48:00:00' then 2
	when (ce.charttime-demo.admittime) > '48:00:00' and (ce.charttime-demo.admittime) <= '72:00:00' then 3
	when (ce.charttime-demo.admittime) > '72:00:00' and (ce.charttime-demo.admittime) <= '96:00:00' then 4
	when (ce.charttime-demo.admittime) > '96:00:00' and (ce.charttime-demo.admittime) <= '120:00:00' then 5
	when (ce.charttime-demo.admittime) > '120:00:01' and (ce.charttime-demo.admittime) <= '144:00:00' then 6
	when (ce.charttime-demo.admittime) > '144:00:01' and (ce.charttime-demo.admittime) <= '168:00:00' then 7
	else NULL
	end as day
from chartevents ce, public.kentran_1_3_demographics_nockd demo
where	demo.icustay_id=ce.icustay_id AND
	ce.itemid in(1538,225690)  --   total bili,total bilirubin
order by ce.icustay_id, ce.charttime
)
--select * from tab1 
,tab2 as
(
select tab1.icustay_id, tab1.day, max(tab1.valuenum) as max_bili
from tab1
group by tab1.icustay_id, tab1.day, tab1.itemid
)
select * into public.kentran_6_1_table_bili from tab2 where day is not null order by tab2.icustay_id, tab2.day;

select * from public.kentran_6_1_table_asat ;
select * from public.kentran_6_1_table_alat ;
select * from public.kentran_6_1_table_alp ;
select * from public.kentran_6_1_table_bili ;

