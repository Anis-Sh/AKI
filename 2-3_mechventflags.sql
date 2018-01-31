
-- a column to indicated whether patient received mechvent
-- for each day (1-7)
-- then join into table 9

set search_path to mimiciii;
drop table if exists public.kentran_2_3_mechventflags;

WITH  
-- temp table with day 1-7
temp (day) AS (VALUES (1),(2),(3),(4),(5),(6),(7))

, temp_mechvent as 
(
select *

from temp cross join public.kentran_2_2_database_ventiles
order by icustay_id, day
)
--select * from temp_mechvent

, tab3 as
(
	select 
		day
		, icustay_id
		, admittime
		, starttime
		, endtime
		, max(ventnum) over (partition by icustay_id) as mechvent

		, case -- flag if a mech event took place during the day
		
		-- start < day-1 * 24 & <= day *24
		-- start of event within the day -> Y
		when extract(epoch from starttime-admittime)/60/60 > ((day -1) *24) 
			and extract(epoch from starttime-admittime)/60/60 <= (day *24) 
			then 'Y'

		-- start <= day-1 *24 & end > day * 24
		-- start the day before, but end in the future -> Y
		when extract(epoch from starttime-admittime)/60/60 <= ((day -1) *24)
			and extract(epoch from endtime-admittime)/60/60 > (day *24)
			then 'Y'

		-- start <= day-1 *24 & end <= day *24 & end > day-1 *24
		-- start the day before, but end within the day -> Y
		when extract(epoch from starttime-admittime)/60/60 <= ((day -1) *24)
			and extract(epoch from endtime-admittime)/60/60 <= (day *24)
			and extract(epoch from endtime-admittime)/60/60 > ((day -1) *24)
			then 'Y'

		else 'N'
	end as mechvent_flag
	from temp_mechvent
	order by icustay_id, day
)
select day
	, icustay_id
	, mechvent_flag
	, count(mechvent_flag) over (partition by icustay_id, day) as mechvent_perday 

into public.kentran_2_3_mechventflags
from tab3
where mechvent_flag = 'Y';

-- must include distinct because it was a short cut
select distinct * from public.kentran_2_3_mechventflags
order by icustay_id, day;


