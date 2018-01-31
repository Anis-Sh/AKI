/*set search_path to mimiciii;
drop table if exists public.kentran_4_4_database_with_vent; 

with tab1 as
(
select table_peep.*
	, table_pplat.avg_pplat
	, table_pplat.max_pplat
	, table_pplat.pplat_time
from 
	public.kentran_4_1_table_peep table_peep
	, public.kentran_4_3_table_pplat table_pplat
where table_peep.icustay_id=table_pplat.icustay_id 
and table_peep.day=table_pplat.day
)
select * from tab1 order by tab1.icustay_id , day

, tab2 as
(
select tab1.*
	, table_paw.avg_paw
	, table_paw.max_paw
	, table_paw.paw_time
from tab1
	, public.kentran_4_2_table_paw table_paw
where tab1.icustay_id=table_paw.icustay_id 
and	tab1.day=table_paw.day
)

--select * from tab2 order by tab2.icustay_id , tab2.day
, tab3 as
(
select  
	sum(tab2.day) as somme_day
	, tab2.icustay_id
from tab2
group by icustay_id, day
)

--select * from tab3 

, tab4 as
(
select tab2.*
from tab2
inner join tab3 on tab2.icustay_id=tab3.icustay_id
where tab3.somme_day>=3
)
select * 
into table public.kentran_4_4_database_with_vent 
from tab4 order by tab4.icustay_id, tab4.day
*/


-- Ken: USe full outer join to better see missing values?
-- Also this helps to show all ICU days from 1-5
set search_path to mimiciii;
drop table if exists public.kentran_4_4_database_with_vent; 

with tab1 as
(
select COALESCE(table_peep.icustay_id, table_pplat.icustay_id) as icustay_id
	, COALESCE(table_peep.day, table_pplat.day) as day
	, table_peep.avg_peep
	, table_peep.max_peep
	, table_peep.peep_time
	, table_peep.peep_twm 
	, table_pplat.avg_pplat
	, table_pplat.max_pplat
	, table_pplat.pplat_time
	, table_pplat.pplat_twm
from 
public.kentran_4_1_table_peep table_peep 
full outer join public.kentran_4_3_table_pplat table_pplat
on table_peep.icustay_id=table_pplat.icustay_id 
and table_peep.day=table_pplat.day
where table_peep.day is not null
or table_pplat.day is not null -- Ken: remove days > 5
)
--select * from tab1 order by icustay_id , day
, tab2 as
(
select COALESCE(tab1.icustay_id, table_paw.icustay_id) as icustay_id
	, COALESCE(tab1.day, table_paw.day) as day
	, tab1.avg_peep
	, tab1.max_peep
	, tab1.peep_time 
	, tab1.peep_twm
	, tab1.avg_pplat
	, tab1.max_pplat
	, tab1.pplat_time
	, tab1.pplat_twm
	, table_paw.avg_paw
	, table_paw.max_paw
	, table_paw.paw_time
	, table_paw.paw_twm
from tab1
full outer join public.kentran_4_2_table_paw table_paw
on tab1.icustay_id=table_paw.icustay_id 
and	tab1.day=table_paw.day
where tab1.day is not null
or table_paw.day is not null -- remove days > 5
)
--select * from tab2 order by tab2.icustay_id , tab2.day

, tab3 as -- Ken: not sure if this is meant to count how many days per icustay_id or not. But old code does not. The below will. 
(
select  
	distinct count(*) over (partition by tab2.icustay_id) as somme_day
	, tab2.icustay_id
from tab2
order by icustay_id
)
--select * from tab3 

, tab4 as -- should be right join, or else you lose individual days
(
select tab2.*
from tab2
right join tab3 on tab2.icustay_id=tab3.icustay_id
where tab3.somme_day>=3
)
select * 
into table public.kentran_4_4_database_with_vent 
from tab4 order by tab4.icustay_id, tab4.day;

select * from public.kentran_4_4_database_with_vent;  




