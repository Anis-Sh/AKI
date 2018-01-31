set search_path to mimiciii;
drop table if exists public.kentran_5_2_table_hemodyn;

with tab1 as
(
select ce.subject_id
	, ce.icustay_id
	, ce.itemid
	, case
		when itemid in (456,52,6702,443,220052,220181,225312) and valuenum > 0 and valuenum < 200 then valuenum -- MeanBP
		else null end as mabp	
	, case 
		when itemid in (220074, 113, 1103) and valuenum > 0 and valuenum < 200 then valuenum -- CVP 
		end as cvp
	, ce.charttime
	, --Ken: need this for TWM
	case
		when itemid in (456,52,6702,443,220052,220181,225312) then 'MeanBP'
		when itemid in (220074, 113, 1103) then 'cvp'
		else 'elsenull'
	end as type
from  chartevents ce, public.kentran_1_3_demographics_nockd demo
where ce.itemid in
	(
	-- MEAN ARTERIAL PRESSURE
	456, --"NBP Mean"
	52, --"Arterial BP Mean"
	6702, --	Arterial BP Mean #2
	443, --	Manual BP Mean(calc)
	220052, --"Arterial Blood Pressure mean"
	220181, --"Non Invasive Blood Pressure mean"
	225312, --"ART BP mean"
	220074 --CVP
	, 113, 1103 -- Ken: missing from the list
	) 
AND ce.icustay_id=demo.icustay_id  
-- and demo.icustay_id between 200075 and 200100 --Ken: for testing only
order by ce.icustay_id, ce.charttime
)
-- select  * from tab1

, tab2 as
(


select  * 
	, case
	
	when cvp is null then null
	
	-- Ken: if there is a cvp value 
	-- and charttime - next chartime < charttime - prev charttime 
	-- and previous mabp is not null
	-- then mpp = prev mabp - cvp
	when cvp is not null 
		and abs(extract(epoch from ((charttime-lead(charttime) OVER(partition by icustay_id ORDER BY charttime))))) >  abs(extract(epoch from((charttime-lag(charttime) OVER(partition by icustay_id ORDER BY charttime)))))
		and (lag(mabp) over(partition by icustay_id order by charttime) is not null) 
		then (lag(mabp) over(partition by icustay_id order by charttime)-cvp )
	
	-- Ken: if there is a cvp value 
	-- and charttime - next chartime <= charttime - prev charttime 
	-- and next mabp is not null
	-- then mpp = next mabp - cvp
	when cvp is not null 
		and abs(extract(epoch from((charttime-lead(charttime) OVER(partition by icustay_id ORDER BY charttime))))) <=  abs(extract(epoch from((charttime-lag(charttime) OVER(partition by icustay_id ORDER BY charttime)))))
		and (lead(mabp) over(partition by icustay_id order by charttime) is not null) 
		then (lead(mabp) over(partition by icustay_id order by charttime)-cvp )
	
	-- Ken: if there is a cvp value 
	-- and charttime - next chartime > charttime - prev charttime 
	-- and prev mabp is not null
	-- then mpp = 2nd previous mabp - cvp
	when cvp is not null 
		and abs(extract(epoch from((charttime-lead(charttime, 2) OVER(partition by icustay_id ORDER BY charttime))))) >  abs(extract(epoch from((charttime-lag(charttime, 2) OVER(partition by icustay_id ORDER BY charttime))))) 
		and (lag(mabp) over(partition by icustay_id order by charttime) is  null) -- if two consecutive measures of cvp
		then (lag(mabp, 2) over(partition by icustay_id order by charttime)-cvp )
	
	-- Ken: if there is a cvp value 
	-- and charttime - next chartime < charttime - prev charttime 
	-- and next mabp is not null
	-- then mpp = 2nd next mabp - cvp
	when cvp is not null 
		and abs(extract(epoch from((charttime-lead(charttime, 2) OVER(partition by icustay_id ORDER BY charttime))))) <  abs(extract(epoch from((charttime-lag(charttime, 2) OVER(partition by icustay_id ORDER BY charttime))))) 
		and (lead(mabp) over(partition by icustay_id order by charttime) is  null) -- if two consecutive measures of cv
		then (lead(mabp, 2) over(partition by icustay_id order by charttime)-cvp )
	
	end as mpp

	--, lead(charttime) OVER(ORDER BY charttime) as prev_date
	--, lead(charttime) OVER(ORDER BY charttime) as next_date
	, (charttime-lag(charttime) OVER(partition by icustay_id ORDER BY charttime)) as diff_prev
	, (charttime-lead(charttime) OVER(partition by icustay_id ORDER BY charttime)) as diff_next
	, lag(mabp) over(partition by icustay_id order by charttime) as prevmabp
	, lead(mabp) over(partition by icustay_id order by charttime) as nextmabp



from tab1
-- where icustay_id < 200099 -- Ken: for testing purpose only
order by icustay_id, charttime
)
-- select  * from tab2 
,  tab3 as
(
select tab2.icustay_id
	, tab2.mabp
	, tab2.cvp
	, tab2.mpp
	, tab2.charttime
	, tab2.type
	, case
		when (tab2.charttime-demo.admittime) <= '24:00:00' then 1
		when (tab2.charttime-demo.admittime) between '24:00:01' and '48:00:00'  then 2
		when (tab2.charttime-demo.admittime) between '48:00:01' and '72:00:00' then 3
		when (tab2.charttime-demo.admittime) between '72:00:01' and '96:00:00'  then 4
		when (tab2.charttime-demo.admittime) between '96:00:01' and '120:00:00' then 5
		when (tab2.charttime-demo.admittime) between '120:00:01' and '144:00:00' then 6
		when (tab2.charttime-demo.admittime) between '144:00:01' and '168:00:00' then 7
	else null
	end as day

	-- To calculate TWM:
	, extract(epoch from (tab2.charttime - lead(tab2.charttime) OVER(partition by tab2.icustay_id, tab2.type ORDER BY tab2.charttime DESC))) /3600 as interval
	
	, tab2.mabp * extract(epoch from (tab2.charttime - lead(tab2.charttime) OVER(partition by tab2.icustay_id, tab2.type ORDER BY tab2.charttime DESC))) /3600 as mabp_x_interval
	
	, tab2.cvp * extract(epoch from (tab2.charttime - lead(tab2.charttime) OVER(partition by tab2.icustay_id, tab2.type ORDER BY tab2.charttime DESC))) /3600 as cvp_x_interval
	
	, tab2.mpp * extract(epoch from (tab2.charttime - lead(tab2.charttime) OVER(partition by tab2.icustay_id, tab2.type ORDER BY tab2.charttime DESC))) /3600 as mpp_x_interval

from public.kentran_1_3_demographics_nockd demo, tab2
where demo.icustay_id=tab2.icustay_id
)

-- select  * from tab3 order by tab3.icustay_id, charttime

, tab4 as -- getting mabp
(
select 	
		icustay_id
		, day
		, avg(mabp) as avg_mabp
		, case
			when sum(interval) in (null, 0)
			or sum(mabp_x_interval) in (null,0)
			then max(mabp)

			else sum(mabp_x_interval)/sum(interval)
		
		end as twm_mabp

from tab3
where day is not null
and mabp is not null
group by icustay_id, day, type
)

--select * from tab4 order by icustay_id, day

, tab5 as
(
select 	
		icustay_id
		, day
		, avg(cvp) as avg_cvp
		, case
			when sum(interval) in (null, 0)
			or sum(cvp_x_interval) in (null,0)
			then max(cvp)

			else sum(cvp_x_interval)/sum(interval)
		
		end as twm_cvp

from tab3
where day is not null
and cvp is not null
group by icustay_id, day, type
)

--select * from tab5 order by icustay_id, day
, tab6 as
(
select 	
		icustay_id
		, day
		, avg(mpp) as avg_mpp
		, case
			when sum(interval) in (null, 0)
			or sum(mpp_x_interval) in (null,0)
			then max(mpp)

			else sum(mpp_x_interval)/sum(interval)
		
		end as twm_mpp

from tab3
where day is not null
and mpp is not null
group by icustay_id, day, type
)

--select * from tab6 order by icustay_id, day

, tab7 as 
(
select 
	coalesce(tab4.icustay_id, tab5.icustay_id, tab6.icustay_id) as icustay_id
	, coalesce(tab4.day, tab5.day, tab6.day) as day
	, tab4.avg_mabp
	, tab4.twm_mabp
	
	, tab5.avg_cvp
	, tab5.twm_cvp
	
	, tab6.avg_mpp
	, tab6.twm_mpp
	

from tab4

full outer join tab5
on tab4.icustay_id=tab5.icustay_id and tab4.day=tab5.day

full outer join tab6
on tab4.icustay_id=tab6.icustay_id and tab4.day=tab6.day

)

select * into public.kentran_5_2_table_hemodyn  
from tab7 order by icustay_id, day;

select * from public.kentran_5_2_table_hemodyn;

--select demo.icustay_id
--from demographics_nockd demo, table_cvp
--where demo.icustay_id=table_cvp.icustay_id
--order by demo.icustay_id