-- creation de la table kdigo
-- join table creat, urine et rrt

set search_path to mimiciii;
drop table if exists public.kentran_8_4_table_kdigo;


with tab1 as
(
select  --Ken: need coalesce to make sure we merge data from all 3 tables
	coalesce(table_creat.icustay_id, table_urine.icustay_id, table_rrt.icustay_id) as icustay_id
	, coalesce(table_urine.day_24h, table_creat.day, table_rrt.day) as day_24h
	, table_urine.day_12h
	, table_urine.day_6h
	, table_creat.creat as creat_max
	, table_urine.urine_6h_kgh
	, table_urine.urine_12h_kgh
	, table_urine.urine_24h_kgh
	, table_rrt.rrt
from public.kentran_8_1_table_creat as table_creat
full join public.kentran_8_2_table_urine table_urine on  table_creat.icustay_id=table_urine.icustay_id and
	table_creat.day=table_urine.day_24h 
full join public.kentran_8_3_table_rrt table_rrt on  table_creat.icustay_id=table_rrt.icustay_id and
	table_creat.day=table_rrt.day 
)

--select* from tab1 order by icustay_id, day_6h


, tab2 as --merge avec data required for KDIGO calculation
(
select tab1.*
	, demo.age
	, demo.ethnicity
	, demo.gender
from tab1, public.kentran_1_3_demographics_nockd demo
where demo.icustay_id=tab1.icustay_id
)

, tab3 as
(
select tab2.*
	, case
		when gender='M' and ethnicity='BLACK/AFRICAN AMERICAN' 
		then 88*(75/(186*(age^ -0.203)*1.210))^(1/-1.154)
		
		when gender='M' and ethnicity!='BLACK/AFRICAN AMERICAN' 
		then 88* (75/(186*(age^ -0.203)))^(1/-1.154)
		
		when gender='F' and ethnicity!='BLACK/AFRICAN AMERICAN' 
		then 88*(75/(186*(age^ -0.203)*0.742))^(1/-1.154)
		
		else 88*(75/(186*(age^ -0.203)*1.210*0.742))^(1/-1.154)
		
		end as mdrd_creat75
from tab2
)

, tab4 as
(
select *
	, case
		when (creat_max/mdrd_creat75 between 1.5 and 1.9) 
		or (creat_max-mdrd_creat75>=26.5)  
		or (urine_6h_kgh<0.5 and urine_12h_kgh >=0.5 and urine_24h_kgh >=3) -- Ken: to avoid misclassification when urine_12h is also <0.5 and urine_24h >=3
		then 1
		
		when (creat_max/mdrd_creat75 between 2 and 2.9) 
		or (urine_12h_kgh<0.5 and urine_24h_kgh >=0.3) -- Ken: to avoid misclassification 
		then 2

		when (creat_max/mdrd_creat75 >=3) 
		or (creat_max-mdrd_creat75>=353.6) 
		or urine_24h_kgh<0.3
		or urine_12h_kgh=0 
		or rrt=1
		then 3
		
		end as kdigo
		, creat_max/mdrd_creat75 as changein_creat
from tab3
)
-- select * from tab4
--select * into table_kdigo from tab4 order by icustay_id, day_24h

--, tab5 as
--(
--select icustay_id
--		,day_24h
--		,day_12h
--		,day_6h
--		,kdigo
--from tab4
--where day_24h is not null --Ken: should not need this after coalesce
--group by icustay_id,day_24h
--order by icustay_id, day_24h, day_6h	
--)
-- select * from tab5

select distinct * into public.kentran_8_4_table_kdigo from tab4 order by icustay_id, day_24h;

select * from public.kentran_8_4_table_kdigo;
--where icustay_id in (select icustay_id from public.kentran_8_4_table_kdigo_daily
--						where max_kdigo_24h != min_kdigo_24h);

