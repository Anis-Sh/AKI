set search_path to mimiciii;
drop table if exists public.kentran_8_4_table_kdigo_daily;


with tab1 as
(
select icustay_id
		,day_24h
		,day_12h
		,day_6h
		,kdigo
from public.kentran_8_4_table_kdigo

order by icustay_id, day_24h, day_6h	
) 
-- select * from tab1
, tab2 as
(
select distinct
		icustay_id
		,day_24h
		,max(kdigo) as max_kdigo_24h
		,avg(kdigo) as avg_kdigo_24h
		,min(kdigo) as min_kdigo_24h
	
from tab1
group by icustay_id, day_24h
)
select * into public.kentran_8_4_table_kdigo_daily
from tab2 order by icustay_id, day_24h;

select * from public.kentran_8_4_table_kdigo_daily;
