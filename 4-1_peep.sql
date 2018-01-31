


set search_path to mimiciii;
drop table if exists public.kentran_4_1_table_peep ;

with tab as 
(
select 
	ce.icustay_id
	,min(ce.charttime) -- get the first entry only
from chartevents ce
where ce.itemid=220339 --   peep set
and ce.icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
group by  ce.icustay_id
limit 1000
)
--select * from tab

,tab1 as
(
select 
	ce.icustay_id
	, ce.itemid
	, ce.charttime
	, ce.valuenum
	, ce.valueuom
	, lead(charttime) OVER(partition by ce.icustay_id ORDER BY charttime DESC) as prev_date -- Ken: need to partition by icustay_id, otherwise the prev_date can be wrong
	, case 
	when (ce.charttime-tab.min) < '24:00:00' then 1
	when (ce.charttime-tab.min) >= '24:00:00' and (ce.charttime-tab.min) < '48:00:00' then 2
	when (ce.charttime-tab.min) >= '48:00:00' and (ce.charttime-tab.min) < '72:00:00' then 3
	when (ce.charttime-tab.min) >= '72:00:00' and (ce.charttime-tab.min) < '96:00:00' then 4
	when (ce.charttime-tab.min) >= '96:00:00' and (ce.charttime-tab.min) < '120:00:00' then 5
	else NULL
	end as day
	-- To calculate TWM:
	, extract(hour from (ce.charttime - lead(charttime) OVER(partition by ce.icustay_id ORDER BY charttime DESC))) as interval
	, valuenum * extract(hour from (ce.charttime - lead(charttime) OVER(partition by ce.icustay_id ORDER BY charttime DESC))) as value_x_interval
from chartevents ce, tab
where tab.icustay_id=ce.icustay_id 
AND ce.itemid=220339 --  peep set
and ce.icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
order by ce.icustay_id, ce.charttime
)
-- select * from tab1 
,tab2 as
(
select 
	tab1.icustay_id
	, tab1.day
	, avg(tab1.valuenum) as avg_peep
	, max(tab1.valuenum) as max_peep
	, sum((tab1.valuenum*(extract(hour from (tab1.charttime-tab1.prev_date))))) as peep_time
	, sum(tab1.interval) as sum_interval
	, sum(tab1.value_x_interval) as sum_value_x_interval
	, case
		when sum(tab1.interval) in (NULL,0)
		or sum(tab1.value_x_interval) in (null,0)
		then max(tab1.valuenum)

		else sum(tab1.value_x_interval)/sum(tab1.interval)

		end as TWM
from tab1
group by tab1.icustay_id, tab1.day, tab1.itemid
)
--select * from tab2 where sum_interval in (null, 0)

select * into public.kentran_4_1_table_peep 
from tab2 
order by tab2.icustay_id, tab2.day;

Select * from public.kentran_4_1_table_peep
;


-- Q: what is Peep time here? Is it the duration between the previous peep record and current one? Why multiply by valunum? And also why group by day?

